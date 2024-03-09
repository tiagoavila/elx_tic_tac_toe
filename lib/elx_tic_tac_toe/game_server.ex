defmodule ElxTicTacToe.GameServer do
  @moduledoc """
  This module is responsible for managing game sessions in the ElxTicTacToe application.
  """

  use GenServer
  require Logger

  alias __MODULE__
  alias ElxTicTacToe.GameState

  # Client

  # The child specification describes how the supervisor starts, shuts down, and restarts child processes.
  # This is called by the DynamicSupervisor when starting the child process in the method: Supervisor.start_link/2
  def child_spec(opts) do
    game_code = Keyword.get(opts, :game_code, GameServer)
    player = Keyword.fetch!(opts, :player)

    %{
      id: "#{GameServer}_#{game_code}",
      start: {GameServer, :start_link, [game_code, player]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  # This starts the GameServer Genserver
  @doc """
  Starts the GameServer Genserver with the game code and the player
  """
  def start_link(game_code, player) do
    case GenServer.start_link(__MODULE__, {game_code, player}, name: via_tuple(game_code)) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info(
          "Already started GameServer #{inspect(game_code)} at #{inspect(pid)}, returning :ignore"
        )

        :ignore

      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """
  Generates a tuple used for referencing a game session via a unique game code in a distributed process registry.

  This function constructs a special tuple recognized by Elixir's process communication system, allowing for the referencing of processes through a `Horde.Registry`. The registry provides a distributed, fault-tolerant mechanism for process lookup, suitable for clustered Elixir applications.

  ## Parameters

    - `game_code`: A unique identifier for the game session. It is used as a key in the `Horde.Registry` to locate the specific game process.

  ## Returns

  Returns a tuple `{:via, Horde.Registry, {ElxTicTacToe.GameRegistry, game_code}}` where:
    - `:via` indicates the use of a custom registry for process lookup.
    - `Horde.Registry` specifies that the Horde library's distributed registry is being used.
    - `ElxTicTacToe.GameRegistry` is the module where game sessions are registered.
    - `game_code` is the unique identifier for the game session, allowing for its retrieval from the registry.

  ## Examples

      iex> via_tuple("game123")
      {:via, Horde.Registry, {ElxTicTacToe.GameRegistry, "game123"}}

  Use this function to obtain a reference to a game session process when sending messages or when linking processes in a distributed Elixir application.

  """
  def via_tuple(game_code) do
    {:via, Horde.Registry, {ElxTicTacToe.GameRegistry, game_code}}
  end

  @doc """
  Starts a new game session or joins an existing one using a specified game code.

  This function attempts to start a new game session for the given game code. If a session with the specified game code is already running, it will proceed with the logic to join the existing game. The function utilizes `Horde.DynamicSupervisor` to manage game session processes in a distributed, fault-tolerant manner.

  ## Parameters

    - `game_code`: A unique identifier for the game session. This code is used to either start a new session or join an existing one.
    - `player`: The player data or identifier that is attempting to start or join the game. This could be a player ID, player struct, or any other representation of a player in the game.

  ## Workflow

  1. Attempts to start a child process under `Tictac.DistributedSupervisor` using `Horde.DynamicSupervisor.start_child/2`.
  2. The child process is defined as `{GameServer, [game_code: game_code, player: player]}`, where `GameServer` is the module responsible for game session logic, and the list contains initialization arguments including the `game_code` and `player`.
  3. If the child process starts successfully (indicating a new game session was created), logs a message and returns `{:ok, :started}`.
  4. If the `start_child` call returns `:ignore`, it indicates that a game session with the specified `game_code` is already running. It then logs a message about joining the existing session. The actual join logic should be implemented in a `join_game` function, which is indicated as a TODO in the code.

  ## Returns

  - `{:ok, :started}`: Indicates that a new game session was successfully started with the provided game code.
  - `{:ok, :joined}`: Should be returned by the `join_game` function (once implemented) to indicate the player successfully joined an existing game session.
  - `{:error, reason}`: Should be returned by the `join_game` function (once implemented) if there was an error joining the existing game session.

  ## Examples

  Assuming `join_game` is implemented:

      iex> start_or_join_game("game123", %Player{id: "player1"})
      {:ok, :started, pid} # If a new game session was started

      iex> start_or_join_game("game123", %Player{id: "player2"})
      {:ok, :joined} # If joining an existing game session
  """
  @spec start_or_join_game(String.t(), any()) :: {:ok, :started, pid} | {:ok, :joined} | {:error, any()}
  def start_or_join_game(game_code, player) do
    case Horde.DynamicSupervisor.start_child(
           ElxTicTacToe.DistributedSupervisor,
           {GameServer, [game_code: game_code, player: player]}
         ) do
      {:ok, pid} ->
        Logger.info("Started game server #{inspect(game_code)}")
        {:ok, :started, pid}

      :ignore ->
        Logger.info("Game server #{inspect(game_code)} already running. Joining")

        case join_game(game_code, player) do
          {:ok, _} -> {:ok, :joined}
          {:error, _reason} = error -> error
        end
    end
  end

  def get_current_state(game_code) do
    GenServer.call(via_tuple(game_code), :get_current_state)
  end

  def join_game(game_code, player) do
    GenServer.call(via_tuple(game_code), {:join_game, player})
  end

  ##########################################################################################

  # Server

  @doc """
  Invoked when the server is started. start_link/3 or start/3 will block until it returns.
  """
  @impl true
  def init({game_code, player}) do
    # Create the new game state with the creating player assigned
    {:ok, GameState.new(game_code, player)}
  end

  @impl true
  def handle_call(:get_current_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:join_game, player}, _from, state) do
    if server_running?(state.code) do
      case GameState.join(state, player) do
        {:error, reason} -> {:reply, {:error, reason}, state}
        state -> {:reply, {:ok, "Game joined"}, state}
      end
    else
      {:reply, {:error, "Game not started"}, state}
    end
  end

  def server_running?(game_code) do
    case Horde.Registry.lookup(ElxTicTacToe.GameRegistry, game_code) do
      [{pid, _}] -> Process.alive?(pid)
      _ -> false
    end
  end
end

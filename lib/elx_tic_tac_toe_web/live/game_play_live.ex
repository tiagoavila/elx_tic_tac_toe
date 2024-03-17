defmodule ElxTicTacToeWeb.GamePlayLive do
  use ElxTicTacToeWeb, :live_view

  alias ElxTicTacToe.GameServer
  alias Phoenix.PubSub

  import ElxTicTacToeWeb.Layouts.GameComponents

  def mount(%{"game" => game_code, "player" => player_id}, _session, socket) do
    if connected?(socket),
      do: PubSub.subscribe(ElxTicTacToe.PubSub, "game-#{game_code}")

    game_state = GameServer.get_current_state(game_code)
    {:ok, socket |> assign(game_code: game_code, player_id: player_id, game: game_state)}
  end

  def handle_info(:game_state_updated, socket) do
    game_state = GameServer.get_current_state(socket.assigns.game_code)
    {:noreply, assign(socket, game: game_state)}
  end

  def handle_event(
        "send_move",
        %{"square" => square, "current_player" => current_player, "game_code" => game_code},
        socket
      ) do
    IO.puts("Received move on square #{square} from player #{current_player}")

    game_state = GameServer.get_current_state(socket.assigns.game_code)

    if current_player == game_state.active_player do
      {:noreply, put_flash(socket, :info, "Funcionou")}
    else
      {:noreply, put_flash(socket, :error, "Não é a sua vez")}
    end
  end
end

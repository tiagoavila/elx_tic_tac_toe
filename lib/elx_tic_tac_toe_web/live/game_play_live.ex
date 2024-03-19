defmodule ElxTicTacToeWeb.GamePlayLive do
  @moduledoc """
  This module is responsible for managing the game play page in the ElxTicTacToe application.
  """

  use ElxTicTacToeWeb, :live_view

  alias ElxTicTacToe.GameServer
  alias ElxTicTacToeWeb.Helpers.PubSubHelper, as: PubSubHelper

  import ElxTicTacToeWeb.Layouts.GameComponents

  def mount(%{"game" => game_code, "player" => player_id}, _session, socket) do
    if connected?(socket),
      do: PubSubHelper.subscribe(game_code)

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

    case GameServer.send_move(game_code, current_player, square) do
      {:ok, new_state} ->
        PubSubHelper.broadcast_game_state(game_code)
        {:noreply, assign(socket, game: new_state)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def handle_event("reset_game", %{"game_code" => game_code}, socket) do
    case GameServer.reset_game(game_code) do
      {:ok, new_state} ->
        PubSubHelper.broadcast_game_state(game_code)

        {:noreply, assign(socket, game: new_state)}

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to reset game")}
    end
  end
end

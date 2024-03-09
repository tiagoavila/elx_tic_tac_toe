defmodule ElxTicTacToeWeb.HomeLive do
  use ElxTicTacToeWeb, :live_view

  alias ElxTicTacToe.{GameStarter, Player, GameServer}

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:changeset, GameStarter.starting_changeset())}
  end

  def handle_event("validate", %{"game_starter" => params}, socket) do
    changeset =
      GameStarter.starting_changeset(params)
      # This makes the validation errors to be shown in the form
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("submit_game", %{"game_starter" => params}, socket) do
    with {:ok, game} <- GameStarter.create(params),
         {:ok, player1} <- Player.create(params),
         {:ok, :started, _} <- GameServer.start_or_join_game(game.game_code, player1) do
      {:noreply,
       redirect(socket,
         to: Routes.game_play_path(socket, :show, game.game_code, player1.player_name)
       )}
    else
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

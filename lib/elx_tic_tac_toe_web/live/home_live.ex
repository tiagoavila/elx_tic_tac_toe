defmodule ElxTicTacToeWeb.HomeLive do
  use ElxTicTacToeWeb, :live_view

  alias ElxTicTacToe.GameStarter

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:changeset, GameStarter.changeset_on_start())}
  end

  def handle_event("validate", %{"game_starter" => params}, socket) do
    {:noreply, assign(socket, changeset: GameStarter.changeset_on_start(params))}
  end

  def handle_event("submit_game",  %{"game_starter" => params}, socket) do
    changeset = GameStarter.changeset_on_creation(params)

    {:noreply, assign(socket, changeset: changeset)}
  end
end

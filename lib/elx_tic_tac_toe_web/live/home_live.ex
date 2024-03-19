defmodule ElxTicTacToeWeb.HomeLive do
  @moduledoc """
  This module is responsible for managing the home page in the ElxTicTacToe application.
  """
  use ElxTicTacToeWeb, :live_view

  alias ElxTicTacToe.{GameStarter, Player, GameServer}
  alias ElxTicTacToeWeb.Helpers.PubSubHelper, as: PubSubHelper

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
         {:ok, player} <- Player.create(params),
         {:ok, game_event} <- GameServer.start_or_join_game(game.game_code, player) do
      IO.puts("Game create #{game.game_code} - player #{player.id}")

      if game_event == :joined,
        do: PubSubHelper.broadcast_game_state(game.game_code)

      {:noreply, push_navigate(socket, to: ~p"/play?game=#{game.game_code}&player=#{player.id}")}
    else
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

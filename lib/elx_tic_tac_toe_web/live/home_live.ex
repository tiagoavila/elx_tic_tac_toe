defmodule ElxTicTacToeWeb.HomeLive do
  use ElxTicTacToeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

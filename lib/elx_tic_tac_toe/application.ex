defmodule ElxTicTacToe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ElxTicTacToeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ElxTicTacToe.PubSub},
      # Start Finch
      {Finch, name: ElxTicTacToe.Finch},
      # Start the Endpoint (http/https)
      ElxTicTacToeWeb.Endpoint
      # Start a worker by calling: ElxTicTacToe.Worker.start_link(arg)
      # {ElxTicTacToe.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElxTicTacToe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElxTicTacToeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

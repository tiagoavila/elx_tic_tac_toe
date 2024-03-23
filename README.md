# ElxTicTacToe

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

To run the application in multi nodes:
In one prompt window:
* set PORT=4000
* iex --name a@127.0.0.1 --cookie asdf -S mix phx.server

In another prompt window:
* set PORT=4001
* iex --name b@127.0.0.1 --cookie asdf -S mix phx.server

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

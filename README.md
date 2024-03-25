# ElxTicTacToe

To start your Phoenix server, follow these steps:

## Setup and Running Locally

1. **Install and Setup Dependencies**
   ```bash
   mix setup
   ```
2. **Start the Phoenix Endpoint**
   You can start the Phoenix server using:
   ```bash
   mix phx.server
   ```
   Alternatively, to start inside IEx (Interactive Elixir), use:
   ```bash
   iex -S mix phx.server
   ```

Now, you can visit [\`localhost:4000\`](http://localhost:4000) from your browser to see your Phoenix application in action.

## Multi-node Setup

To run the application in multi nodes, you'll need to open two prompt windows and set them up as follows:

**In the first prompt window:**
```bash
set PORT=4000
iex --name a@127.0.0.1 --cookie asdf -S mix phx.server
```

**In the second prompt window:**
```bash
set PORT=4001
iex --name b@127.0.0.1 --cookie asdf -S mix phx.server
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

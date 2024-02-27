import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elx_tic_tac_toe, ElxTicTacToeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "udeDrhh/xp0psyxBxW1u6HpnXK+haacvRw1NpBtqDmqbTQj0JDtYKpCXfM8J5omk",
  server: false

# In test we don't send emails.
config :elx_tic_tac_toe, ElxTicTacToe.Mailer,
  adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

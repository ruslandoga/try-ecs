import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :e, EWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "6q1igU6NyGIRBCEv+27ZQtMcnYQqDCsnd7jAo/PSoE8RXWaSHK0ZqGVtUYJ3rldW",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

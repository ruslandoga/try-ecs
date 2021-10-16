import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :e, EWeb.Endpoint,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    url: [host: System.fetch_env!("WEB_HOST"), port: 80],
    secret_key_base: secret_key_base,
    server: true

  ec2_polling_interval = String.to_integer(System.get_env("EC2_POLL_INTERVAL_SECONDS") || "5")

  config :libcluster,
    topologies: [
      aws: [
        strategy: E.Cluster.Strategy,
        config: [
          app_prefix: :e,
          name: System.get_env("EC2_NAME") || "megapool",
          polling_interval: :timer.seconds(ec2_polling_interval),
          regions: ["eu-north-1", "ap-southeast-1"]
        ]
      ]
    ]

  config :logger, metadata: [:request_id, :node]
end

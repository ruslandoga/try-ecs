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
    # export WEB_HOST=edify.space
    url: [host: System.fetch_env!("WEB_HOST"), port: 80],
    secret_key_base: secret_key_base,
    server: true

  ec2_polling_interval = String.to_integer(System.get_env("EC2_POLL_INTERVAL_SECONDS") || "5")

  # export EC2_REGIONS=eu-north-1,ap-southeast-1,us-west-1
  regions = "EC2_REGIONS" |> System.fetch_env!() |> String.split(",")

  config :libcluster,
    topologies: [
      aws: [
        strategy: E.Cluster.Strategy,
        config: [
          app_prefix: :e,
          name: System.get_env("EC2_NAME") || "megapool",
          polling_interval: :timer.seconds(ec2_polling_interval),
          regions: regions
        ]
      ]
    ]

  # TODO use cidr like in PRIMARY_SUBNET=10.0.0.0/16
  # export PRIMARY_HOST_PREFIX=10.0.
  config :e, primary_prefix: System.fetch_env!("PRIMARY_HOST_PREFIX")

  # TODO set to read only for replicas
  if url = System.get_env("DATABASE_URL") do
    if url != "" do
      config :e, E.Repo,
        url: url,
        pool_size: String.to_integer(System.get_env("POOL_SIZE") || "20")
    end
  end

  config :logger, metadata: [:request_id, :node]
end

if config_env() == :dev do
  config :e, E.Repo, url: "ecto://postgres:postgres@localhost:5432/t_dev"
end

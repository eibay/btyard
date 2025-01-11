import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :btyard, BtyardWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Btyard.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
config :btyard, Btyard.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true,
  ssl_opts: [
    verify: :verify_none,
    cacerts: :public_key.cacerts_get()
  ]
  # ssl: [cacertfile: "priv/certs/ca.pem"]
  # ssl_opts: [
  #   cacertfile: Path.expand("priv/certs/ca.pem")
  # ]

config :btyard, BtyardWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true

config :btyard, BtyardWeb.Endpoint,
  url: [host: "btyard.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: [
    "//btyard.com",
    "//www.btyard.com",
    "//btyard.gigalixirapp.com/"
  ]

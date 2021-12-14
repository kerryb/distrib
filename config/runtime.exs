import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# Start the phoenix server if environment is set and running in a  release
if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
  config :distrib, DistribWeb.Endpoint, server: true
end

case config_env() do
  :dev ->
    # For development, we disable any cache and enable
    # debugging and code reloading.
    #
    # The watchers configuration can be used to run external
    # watchers to your application. For example, we use it
    # with esbuild to bundle .js and .css sources.
    port = String.to_integer(System.get_env("PORT") || "4000")

    config :distrib, DistribWeb.Endpoint,
      # Binding to loopback ipv4 address prevents access from other machines.
      # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
      http: [ip: {127, 0, 0, 1}, port: port],
      check_origin: false,
      code_reloader: true,
      debug_errors: true,
      secret_key_base: "/zuEOO7TsJMgIWo8yxb9NfILEoFk1cbWY/XmIpPsYu3K3pRqWj0YDEhhxJB6wzXA",
      watchers: [
        # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
        esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}
      ]

  :prod ->
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

    host = System.get_env("PHX_HOST") || "example.com"
    port = String.to_integer(System.get_env("PORT") || "4000")

    config :distrib, DistribWeb.Endpoint,
      url: [host: host, port: 443],
      http: [
        # Enable IPv6 and bind on all interfaces.
        # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
        # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
        # for details about using IPv6 vs IPv4 and loopback vs public addresses.
        ip: {0, 0, 0, 0, 0, 0, 0, 0},
        port: port
      ],
      secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :distrib, DistribWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
  _ ->
    :ok
end

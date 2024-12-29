import Config

# configuração para a API do discord
config :nostrum,
  token: System.get_env("IFFY_DISCORD"),
  gateway_intents: [
    :guilds,
    ],
  youtubedl: nil

# configuração para o scheduler
config :iffy, Iffy.Scheduler,
  jobs: [
    # Roda o fetcher cada hora
    {"@hourly", {Iffy, :do_stuff, []}}
  ]

config :logger,
  level: :info

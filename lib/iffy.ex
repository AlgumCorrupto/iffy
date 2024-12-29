defmodule Iffy do
  @moduledoc """
  Ponto de entrada para o bot
  """

  import Iffy.Fetcher
  import Iffy.Discord.Sender
  require Logger

  use Application
  @impl true
  def start(_type, _args) do
    children = [
      {Iffy.Discord.Consumer, []},
      {Iffy.Scheduler, []},
    ]

    :ets.new(:discord_channels, [:set, :public, :named_table])
    :ets.insert(:discord_channels, {"channel", []})

    opts = [strategy: :one_for_one, name: Iffy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def do_stuff, do:
    do_fetch() |> broadcast

end

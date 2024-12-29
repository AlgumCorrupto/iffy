defmodule Iffy.Discord.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Api

  require Logger
  # each handle_event handles an unique event
  def handle_event({:READY, _ready_args, _ws_state}) do
    guilds = Api.get_current_user_guilds!
    channels = for guild <- guilds do
      channel = guild.id
      |> Api.get_guild_channels!
      |> Enum.filter(&(&1.name == target_channel()))
      case channel do
        []  -> nil
        _   -> hd(channel)
      end
    end
    |> Enum.filter(&(&1 != nil))
    |> Enum.map(&(&1.id))
    :ets.insert(:discord_channels, {"channel", channels})
    log_state()

    Iffy.do_stuff()
  end

  # evento para quando o bot entra numa nova guilda (server)
  def handle_event({:GUILD_AVAILABLE, guild, _ws_state}) do
    channels = lookup()
    posible_new_channel = guild.id |> Api.get_guild_channels!
    |> Enum.find(&(&1.name == target_channel()))

    unless (posible_new_channel == nil) || (posible_new_channel in channels) do
      :ets.insert(:discord_channels, {"channel", [posible_new_channel.id] ++ channels})
    end

    log_state()
  end

  def handle_event({:CHANNEL_CREATE, channel, _ws_state}) do
    if channel.name == target_channel() do
      channels = lookup()
      :ets.insert(:discord_channels, {"channel", [channel.id] ++ channels})
      log_state()
    end
  end

  def handle_event({:CHANNEL_UPDATE, {before_change, after_change}, _ws_state}) do
    channels = lookup()
    if before_change.name == target_channel() do
      :ets.insert(:discord_channels, {"channel",  channels -- [after_change.id]})
      log_state()
    end
    if after_change.name == target_channel() do
      :ets.insert(:discord_channels, {"channel", Enum.uniq([after_change.id] ++ channels)})
      log_state()
    end
  end

  def handle_event({:CHANNEL_DELETE, channel, _ws_state}) do
    channels = lookup()
    channels |> inspect() |> Logger.debug()
    :ets.insert(:discord_channels, {"channel", channels -- [channel.id]})
    log_state()
  end

  # para depuração
  def handle_event({ev}), do:
    ev |> elem(0) |> inspect |> Logger.debug

  defp lookup, do:
    :ets.lookup(:discord_channels, "channel") |> hd |> elem(1)

  defp target_channel, do:
    "iff-notícias"

  defp log_state, do:
    :ets.lookup(:discord_channels, "channel") |> inspect |> Logger.debug
end

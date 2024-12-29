defmodule Iffy.Discord.Sender do
  alias Nostrum.Api

  require Logger
  def broadcast(articles) do
    Logger.info("Broadcasting messages to discord")
    channels = :ets.lookup(:discord_channels, "channel") |> hd |> elem(1)
    do_cast(articles, channels)
  end

  defp do_cast(_, []) do
    :ok
  end
  defp do_cast(articles, channels) do
    cast_all_articles(articles, hd(channels))

    do_cast(articles, tl(channels))
  end

  defp cast_all_articles([], _) do
    :ok
  end
  defp cast_all_articles([current | next], channel) do
    import Nostrum.Struct.Embed
    embed =
      %Nostrum.Struct.Embed{}
      |> put_title(current["title"])
      |> put_description(current["desc"])
      |> put_author(current["topic"], nil, nil)
      |> put_url(current["url"])
      |> kinda_put_img(current["img"])

    case Api.create_message(channel, embed: embed) do
      {:error, _} -> remove_channel_from_list(channel)
      _           -> cast_all_articles(next, channel)
    end
  end

  defp remove_channel_from_list(channel) do
    channels = :ets.lookup(:discord_channels, "channel") |> hd |> elem(1)

    :ets.new(:discord_channels, {"channel", channels -- [channel]})
    :error
  end

  defp kinda_put_img(embed, img) do
    unless img == nil do
      embed |> Nostrum.Struct.Embed.put_thumbnail(img)
    else
      embed
    end
  end
end

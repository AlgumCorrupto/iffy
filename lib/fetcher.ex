defmodule Iffy.Fetcher do
  require Logger

  # função principal para esse módulo,
  # bem auto-explicativo como o processo de fetch funciona pela sintaxe do operador pipe |>
  def do_fetch, do: fetch_news_articles() |> parse_html |> compare_and_write_to_mem

  defp fetch_news_articles do
    {:ok, process} = Finch.start_link(name: :fetcher)
    response = get_til_good()

    Process.exit(process, :normal)
    response.body
  end

  defp parse_html(html) do
    {:ok, doc} = html |> Floki.parse_document()
    parsed_doc = doc |> Floki.find("div.tileContent")

    # retornando uma lista de artigos
    # um artigo é composto por url, título e subtítulo
    for article <- parsed_doc do
      %{
        "desc" =>
          article
          |> Floki.find("span.description")
          |> Floki.text(),
        "img" => article |> Floki.find("img.tileImage") |> Floki.attribute("src") |> list_or_nil,
        "url" => article |> Floki.find("a.summary") |> Floki.attribute("href") |> hd,
        "title" =>
          article
          |> Floki.find("a.summary")
          |> Floki.text(),
        "topic" =>
          article
          |> Floki.find("span.subtitle")
          |> Floki.text()
      }
    end
  end

  def write_buff() do
    {:ok, contents} = File.read("./buff")
    {:ok, file} = File.open("./last", [:write])
    IO.binwrite(file, contents)
  end

  defp compare_and_write_to_mem(articles) do
    last_articles = File.read("./last") |> get_last_articles
    new_articles = articles -- last_articles

    encoded = articles |> Jason.encode!()
    {:ok, file} = File.open("./buff", [:write])
    IO.binwrite(file, encoded)

    # retorna new_articles ou uma lista vazia
    if articles != new_articles do
      new_articles
    else
      []
    end
  end

  # utils
  defp list_or_nil(list) do
    if list == [] do
      nil
    else
      hd(list)
    end
  end

  # do a get request to the endpoint til it returns an ok response lol
  defp get_til_good,
    do:
      Finch.build(
        :get,
        "https://portal1.iff.edu.br/o-iffluminense/noticias/ultimas-noticias",
        [{"User-Agent", "villaca.p@gsuite.iff.edu.br"}]
      )
      |> Finch.request(:fetcher)
      |> get_til_good

  defp get_til_good({:error, _}), do: get_til_good()
  defp get_til_good({:ok, response}), do: response

  defp get_last_articles({:ok, contents}), do: Jason.decode!(contents)
  defp get_last_articles({:error, _}), do: []
end

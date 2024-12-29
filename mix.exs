defmodule Iffy.MixProject do
  use Mix.Project

  def project do
    [
      app: :iffy,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Iffy, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.10.0"},        # discord api thingy
      {:quantum, "~> 3.0"},           # cron like thingy
      {:finch, "~> 0.19"},            # http client thingy
      {:gen_stage, "~> 1.2.1"},       # data channel thingy
      {:floki, "~> 0.37.0"},          # html parser thingy
      {:jason, "~> 1.4.4"},           # json parser thingy
    ]
  end
end


# Created by Patrick Schneider on 05.12.2016.
# Copyright (c) 2016,2020 MeetNow! GmbH

defmodule Snowflakex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :snowflakex,
      version: "1.1.1",
      description: "A service for generating unique ID numbers at high scale with some simple guarantees",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps(),

      name: "Snowflakex",
      source_url: "https://github.com/meetnow/snowflakex",
      homepage_url: "https://github.com/meetnow/snowflakex",
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  def application do
    [
      mod: {Snowflakex, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Patrick Schneider <patrick.schneider@meetnow.eu>"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/meetnow/snowflakex"}
    ]
  end
end

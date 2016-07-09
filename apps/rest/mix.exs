defmodule Rest.Mixfile do

  use Mix.Project

  def project do
    [app: :rest,
    version: "0.0.1",
    build_path: "../../_build",
    config_path: "../../config/config.exs",
    deps_path: "../../deps",
    lockfile: "../../mix.lock",
    elixir: "~> 1.2",
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps: deps]
  end

  def application do
    [applications: [:maru, :store]]
  end

  def deps do
    [{:maru, "~> 0.10"}]
  end


end

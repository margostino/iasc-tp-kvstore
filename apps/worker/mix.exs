defmodule Worker.Mixfile do
  
  use Mix.Project

  def project do
    [app: :worker,
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
    [applications: [:logger],
     mod: {WorkerApp, []}]
  end

  defp deps do
    []
  end

end

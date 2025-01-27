defmodule ExEmail.MixProject do
  use Mix.Project

  @scm_url "https://github.com/synchronal/ex_email"
  @version "0.1.0"

  def project,
    do: [
      app: :ex_email,
      deps: deps(),
      description: "Helpers for validating email addresses",
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.16",
      homepage_url: @scm_url,
      name: "ExEmail",
      package: package(),
      source_url: @scm_url,
      start_permanent: Mix.env() == :prod,
      version: @version
    ]

  def application,
    do: [
      extra_applications: [:logger]
    ]

  def cli,
    do: [
      preferred_envs: [
        credo: :test,
        dialyzer: :test
      ]
    ]

  # # #

  defp deps,
    do: [
      {:abnf_parsec, "~> 1.2", github: "sax/abnf_parsec", branch: "fix-nimble-parsec-deprecations", runtime: false},
      {:credo, "> 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "> 0.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "> 0.0.0", only: :dev, runtime: false},
      {:mix_audit, "> 0.0.0", only: [:dev, :test], runtime: false}
    ]

  defp dialyzer,
    do: [
      plt_add_apps: [:ex_unit, :mix],
      plt_add_deps: :app_tree,
      plt_core_path: "_build/plts/#{Mix.env()}",
      plt_local_path: "_build/plts/#{Mix.env()}"
    ]

  defp docs,
    do: [
      main: "ExEmail",
      extras: ["LICENSE.md", "CHANGELOG.md"]
    ]

  defp package,
    do: [
      files: ~w(lib .formatter.exs mix.exs priv/parser/* *.md),
      licenses: ["MIT"],
      maintainers: ["synchronal.dev", "Erik Hanson", "Eric Saxby"],
      links: %{"GitHub" => @scm_url}
    ]
end

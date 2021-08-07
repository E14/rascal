defmodule Rascal.MixProject do
	use Mix.Project

	def project do
		[
			app: :rascal,
			version: "0.1.0",
			elixir: "~> 1.12",
			description: "A chaos monkey for BEAM processes",

			start_permanent: Mix.env() == :dev,
			package: package(),
			deps: deps()
		]
	end

	# Run "mix help compile.app" to learn about applications.
	def application do
		[
			extra_applications: [:logger],
			mod: {Rascal.Application, []}
		]
	end

	defp package do
		[
			source_url: "https://github.com/e14/rascal.git",
			licenses: ["Apache-2.0"]
		]
	end

	# Run "mix help deps" to learn about dependencies.
	defp deps do
		[
			# {:dep_from_hexpm, "~> 0.3.0"},
			# {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
		]
	end
end

defmodule Rascal.Application do
	@moduledoc false
	use Application

	@impl true
	def start(_type, _args) do
		children = [
			# Starts a worker by calling: Rascal.Worker.start_link(arg)
			{Rascal.Scheduler, get_config([:active])}
		]

		# See https://hexdocs.pm/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Rascal.Supervisor]
		Supervisor.start_link(children, opts)
	end

	defp get_config_(key, default \\ nil) when is_atom(key) do
		Application.get_env(:rascal, key, default)
	end

	defp get_config(keys) when is_list(keys) do
		keys
		|> Stream.map(fn key -> {key, Application.get_env(:rascal, key)} end)
		|> Stream.filter(fn {_, v} -> v != nil end)
		|> Enum.into(%{})
	end
end

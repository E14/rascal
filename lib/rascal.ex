defmodule Rascal do
	@moduledoc """
	
	"""
	require Logger
	alias Rascal.Prank
	use Application

	@well_known_processes %{
		Rascal: true,
		erts_code_purger: true,
		erts_literal_area_collector: true,
		socket_registry: true
	}

	@impl Application
	def start(_type, _args) do
		cfg = %{
			Application.fetch_env!(__MODULE__, :key1),
		}
		Logger.info("Rascal will prank random processes.")
		children = [
			{GenServer, }
		]
		opts = [
			strategy: :one_for_one,
			# name: Vexel.Supervisor,
			restart: :transient
		]
		{:ok, _pid} = Supervisor.start_link(children, opts)
	end

	@impl Application
	def stop(_state) do
	end

	@doc """
	Find out whether running in IEx repl. This is used to avoid parent processes necessary for
	running the repl.
	"""
	def iex?() do
		if function_exported?(IEx, :started?, 0) do
			IEx.started?()
		else
			false
		end
	end

	@doc """
	Tries to bring down a random process
	"""
	def prank!() do
		target() |> prank!()
	end

	def prank!(pid) when is_pid(pid) do
		pid |> shout() |> Prank.perform()
	end

	def prank!(pid) do
		pidify(pid) |> prank!()
	end

	def target() do
		Process.list
		|> Enum.filter(fn pid -> !@well_known_processes[Process.info(pid)[:registered_name]] end)
		|> Enum.random
	end

	@doc """
	Returns processes without links
	"""
	def loners() do
		Process.list()
		|> Stream.filter(fn p -> Enum.count(Process.info(p)[:links]) == 0 end)
		|> Enum.into([])
	end

	defp shout(pid) do
		info = Process.info(pid)
		Logger.info("Targeting pid #{pid}, with name #{info[:registered_name]}")
		pid
	end

	defdelegate pidify(pid), to: Rascal.Pidify
	defdelegate pidify(pid, message), to: Rascal.Pidify

	defp get_config(key) when is_atom(key) do
		Application.fetch_env!(__MODULE__, key)
	end
end

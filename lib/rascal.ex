defmodule Rascal do
	@moduledoc """
	A chaos monkey for Beam processes.
	"""
	require Logger
	alias Rascal.Prank

	# Well-known processes are processes that we don't want to kill for various reasons. Eg. we
	# don't want to try to kill the init process, we need to assume it's stable.
	@well_known_processes %{
		:init => true,
		:application_controller => true, # Fair enough.
		Rascal.Application => true, # Rascal would restart, but couldn't check reappearing process
		Mix.ProjectStack => true, # Assuming Mix is not used in production, so this is fine
		Mix.TasksServer => true, # Assuming Mix is not used in production, so this is fine
	}

	# Well-known processes that, in the opinion of the author, should not require special handling.
	# They should rather be resilient against linked processes crashing (trapping the signal), or be
	# supervised processes instead.
	@well_known_processes2 %{
		:erts_code_purger => true,
		:erl_prim_loader => true,
		:kernel_refc => true, # IEx stops if this is targeted
		:erts_literal_area_collector => true,
		:socket_registry => true,
	}

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
	Targets processes randomly with a `probability` chance of killing them.
	"""
	def thanos_snap!(probability \\ 0.5) do
		targets()
		|> Stream.filter(fn _ -> :rand.uniform() > probability end)
		|> Enum.each(&prank!/1)
	end

	@doc """
	Try to bring down a random process.
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

	defp filter_pid(pid) do
		info = Process.info(pid)

		!@well_known_processes[info[:registered_name]]
			and !@well_known_processes2[info[:registered_name]]
			and pid != pidify("0.1.0")
			and !supervisor?(info)
	end

	@doc """
	Select a target PID.
	"""
	def target() do
		targets()
		|> Enum.random
	end

	@doc """
	Generate a stream of valid target PIDs.
	"""
	def targets() do
		Process.list
		|> Stream.filter(&filter_pid/1)
	end

	@doc """
	Returns processes without links.

	This is a utility function for debugging.
	"""
	def loners() do
		Process.list()
		|> Stream.filter(fn p -> Enum.count(Process.info(p)[:links]) == 0 end)
		|> Enum.to_list()
	end

	@doc """
	Returns processes that are a `Supervisor`.

	This is a utility function for debugging. As there is no sane way to crash a
	supervisor, this method should help with debugging
	"""
	def supervisors() do
		Process.list()
		|> Stream.filter(&supervisor?/1)
		|> Enum.to_list()
	end

	defp supervisor?(pid) when is_pid(pid), do: supervisor?(Process.info(pid))
	defp supervisor?(info), do: match?({:supervisor, _, 1}, info[:dictionary][:"$initial_call"])

	defp shout(pid) do
		info = Process.info(pid)
		Logger.info("Targeting #{inspect(pid)} with name `#{inspect(info[:registered_name])}`")
		pid
	end

	defdelegate pidify(pid), to: Rascal.Pidify
	defdelegate hold(), to: Rascal.Scheduler
end

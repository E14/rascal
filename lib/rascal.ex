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
		:application_controller => true,
		Rascal.Application => true,
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
		Mix.ProjectStack => true, # This is not restarted automatically
		Mix.TasksServer => true, # This is not restarted automatically
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
	end

	@doc """
	Find a target.
	"""
	def target() do
		Process.list
		|> Enum.filter(&filter_pid/1)
		|> Enum.random
	end

	@doc """
	Returns processes without links.
	"""
	def loners() do
		Process.list()
		|> Stream.filter(fn p -> Enum.count(Process.info(p)[:links]) == 0 end)
		|> Enum.to_list()
	end

	defp shout(pid) do
		info = Process.info(pid)
		Logger.info("Targeting #{inspect(pid)} with name `#{inspect(info[:registered_name])}`")
		pid
	end

	defdelegate pidify(pid), to: Rascal.Pidify
end

defmodule Rascal.Prank do
	require Logger

	@doc """
	Performs a prank on the given target.
	"""
	def perform(pid) do
		identify(pid)
		|> peek(pid)
		|> kill(pid)
	end

	defp identify(pid) do
		info = Process.info(pid)
		IO.inspect(info)
		:link
	end

	defp peek(any, pid) do
		Logger.info("Peek: #{inspect({any, pid})}")
		any
	end

	defp kill(:link, pid), do: link_kill(pid)
	defp kill(:kill, pid), do: exit_kill(pid)
	defp kill(:normal, pid), do: exit_kill(pid, :psych!)

	@doc """
	Sends an exit signal to a process.
	
	This is almost guaranteed to kill a process (with `:kill` as argument), but behaves differently
	than a crash. Processes stuck in NIFs may ignore even this.
	"""
	def exit_kill(pid, reason \\ :kill) do
		Rascal.pidify(pid)
		|> Process.exit(reason)
	end

	@doc """
	Spawns a new process that links itself to another process and then terminates by raising an
	error.

	This is the most "realistic" way of killing a process.
	"""
	def link_kill(pid, message \\ "psych!") when is_pid(pid) do
		spawn(fn -> :erlang.link(pid); raise message end)
	end

	@doc """
	Agents run a term within their process, so they're an easy target to inject malicious code. This
	method simply sends a message to an agent that immediately raises an exception.
	"""
	def agent_kill(pid, message \\ "psych!") when is_pid(pid) do
		Agent.cast(pid, fn _ -> raise message end)
	end
end

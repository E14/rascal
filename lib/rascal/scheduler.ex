defmodule Rascal.Scheduler do
	use GenServer
	require Logger, as: Log
	alias Rascal.Pidify

	@interval {1000, 10000}
	@check_after 1000

	def start_link(init_arg) do
		GenServer.start_link(__MODULE__, init_arg, [])
	end

	@impl true
	def init(_args) do
		Log.info("Rascal is scheming.")
		scheme()
		{:ok, {}}
	end

	@impl true
	def handle_info(:run, state) do
		scheme()
		{pid, name} = Rascal.prank!()
		if name != nil do
			Process.send_after(self(), {:check, pid, name}, @check_after)
		end
		{:noreply, state}
	end

	@impl true
	def handle_info({:check, pid, name}, state) when is_atom(name) do
		validate!(pid, name)
		{:noreply, state}
	end

	defp scheme() do
		Process.send_after(self(), :run, interval())
	end

	@doc """
	Verify that a named process was restarted.
	"""
	def validate!(pid, name) when is_pid(pid) do
		if !Pidify.pid_from_name(name) do
			Log.error("Named proccess #{name} was not restarted within #{@check_after}ms")
		else
			Log.debug("Found named process #{inspect(name)} as #{inspect(Pidify.pid_from_name(name))} after #{@check_after}")
		end
	end

	defp interval() do
		{min, max} = @interval
		trunc(min + (max - min) * :rand.uniform())
	end
end
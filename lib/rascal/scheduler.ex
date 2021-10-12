defmodule Rascal.Scheduler do
	use GenServer
	require Logger, as: Log
	alias Rascal.Pidify

	@interval {1_000, 30_000}
	@check_after 1000

	def start_link(init_arg) do
		GenServer.start_link(__MODULE__, init_arg, [name: __MODULE__])
	end

	def init_([active: s]) do
		if s do
			Log.info("Rascal is scheming.")
		end
		state = [active: s]
		timer(state)
		{:ok, state}
	end

	@impl true
	def init(args) do
		state = %{active: args[:active]}
		if state[:active] do
			Log.info("Rascal is scheming.")
		end
		timer(state)
		{:ok, state}
	end

	@impl true
	def handle_info(:run, state) do
		timer(state)
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

	@impl true
	def handle_cast(:hold, _state) do
		Log.info("Hold the Rascal")
		{:noreply, [active: false]}
	end

	@impl true
	def handle_cast(:start, _state) do
		Log.info("Let the Rascal go")
		{:noreply, [active: true]}
	end

	@doc """
	Verify that a named process was restarted.
	"""
	def validate!(pid, name) when is_pid(pid) do
		case {pid, Pidify.pid_from_name(name)} do
			{_p, nil} ->
				Log.error("Named proccess #{name} was not restarted within #{@check_after}ms")
			{p, p} -> 
				Log.error("Named process #{inspect(name)} PID didn't change from #{inspect(p)} after #{@check_after}ms")
			{_p, pfn} ->
				Log.debug("Found named process #{inspect(name)} as #{inspect(pfn)} after #{@check_after}ms")
		end
	end

	def hold() do
		GenServer.cast(__MODULE__, :hold)
	end

	defp timer(state) do
		if state[:active] do
			Process.send_after(self(), :run, interval())
		end
	end

	defp interval() do
		{min, max} = @interval
		trunc(min + (max - min) * :rand.uniform())
	end
end
defmodule Rascal.Scheduler do
	use GenServer
	require Logger, as: Log

	@interval {500, 5000}

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
	def handle_info(msg = :run, state) do
		scheme()
		Log.info("Handle info #{inspect(msg)} #{inspect(state)}")
		{:noreply, state}
	end

	defp scheme() do
		Process.send_after(self(), :run, interval())
	end

	defp interval() do
		{min, max} = @interval
		Float.floor(min + (max - min) * :rand.uniform())
	end
end
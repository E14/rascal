defmodule RascalTest do
	use ExUnit.Case
	doctest Rascal
	alias Rascal.Pidify

	test "can kill agent" do
		{state_pid, state_pn} = RascalTest.State.start_link();
		assert state_pid == Pidify.pid_from_name(state_pn)
		Rascal.prank!(state_pid)
		
		ref = Process.monitor(state_pid)

		assert_receive({:DOWN, ^ref, :process, ^state_pid, _reason}, 500)
	end

	defmodule State do
		use Agent

		def start_link() do
			{:ok, pid} = Agent.start(fn -> 1 end, name: __MODULE__)
			{pid, __MODULE__}
		end
	end
end

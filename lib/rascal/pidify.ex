defmodule Rascal.Pidify do
	@moduledoc """
	
	"""

	@doc """
	Turn various representations of a PID into an actual PID.

	# Examples
	```
	iex> self() == pidify(self())
	true
	iex> pidify(1)
	#PID<0.1.0>
	```
	"""
	def pidify(a) when is_pid(a), do: a
	def pidify("#PID" <> a), do: :erlang.list_to_pid(to_charlist(a))
	def pidify(a) when is_binary(a), do: :erlang.list_to_pid('<#{a}>')
	def pidify(a) when is_atom(a), do: pid_from_name(a)
	def pidify(a, b \\ 0) when is_integer(a) and a >= 0 and is_integer(b) and b >= 0, do: pid(0, a, 0)

	@doc """
	Turn 3 non-negative integers into a PID.
	"""
	def pid(a, b, c) when is_integer(a) and is_integer(b) and is_integer(c) do
		:erlang.list_to_pid('<#{a}.#{b}.#{c}>')
	end

	@doc """
	Finds a PID for a given registered name (atom).
	"""
	def pid_from_name(a) when is_atom(a) do
		Process.list()
		|> Enum.find(fn p -> Process.info(p)[:registered_name] == a end)
	end
end


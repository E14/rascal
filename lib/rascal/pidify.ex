defmodule Rascal.Pidify do
	@moduledoc """
	A utility module to work with Beam process identifiers.
	"""

	@doc """
	Turn various representations of a PID into an actual PID.

	# Examples
	```
	iex> self() == #{__MODULE__}.pidify(self())
	true
	iex> #{__MODULE__}.pidify(1)
	#PID<0.1.0>
	iex> #{__MODULE__}.pidify("#PID<0.0.0>")
	#PID<0.0.0>
	iex> #{__MODULE__}.pidify("0.0.1")
	#PID<0.0.1>
	iex> #{__MODULE__}.pidify(1, 2)
	#PID<0.1.2>
	iex> #{__MODULE__}.pidify(:erts_code_purger)
	...> |> Process.info
	...> |> Keyword.get(:registered_name)
	:erts_code_purger
	```
	"""
	def pidify(a) when is_pid(a), do: a
	def pidify("#PID" <> a), do: :erlang.list_to_pid(to_charlist(a))
	def pidify(a) when is_binary(a), do: :erlang.list_to_pid('<#{a}>')
	def pidify(a) when is_atom(a), do: pid_from_name(a)
	def pidify(a, b \\ 0) when is_integer(a) and a >= 0 and is_integer(b) and b >= 0, do: pid(0, a, b)

	@doc """
	Turn 3 non-negative integers into a PID.

	# Examples
	```
	iex> self() == #{__MODULE__}.pidify(self())
	true
	iex> #{__MODULE__}.pid(0, 2, 3)
	#PID<0.2.3>
	```
	"""
	def pid(a, b, c) when is_integer(a) and is_integer(b) and is_integer(c) do
		:erlang.list_to_pid('<#{a}.#{b}.#{c}>')
	end

	@doc """
	Finds a PID for a given registered name (atom).

	# Examples
	```
	iex> #{__MODULE__}.pid_from_name(:erts_code_purger)
	...> |> Process.info
	...> |> Keyword.get(:registered_name)
	:erts_code_purger
	```
	"""
	def pid_from_name(a) when is_atom(a) do
		Process.list()
		|> Enum.find(fn p -> Process.info(p)[:registered_name] == a end)
	end
end


defmodule RascalTest do
  use ExUnit.Case
  doctest Rascal

  test "greets the world" do
    assert Rascal.hello() == :world
  end
end

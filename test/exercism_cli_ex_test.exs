defmodule ExercismCliExTest do
  use ExUnit.Case
  doctest ExercismCliEx

  test "greets the world" do
    assert ExercismCliEx.hello() == :world
  end
end

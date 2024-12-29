defmodule IffyTest do
  use ExUnit.Case
  doctest Iffy

  test "greets the world" do
    assert Iffy.hello() == :world
  end
end

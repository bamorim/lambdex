defmodule Lambdex.Church.FactorialTest do
  use ExUnit.Case

  alias Lambdex.Church.Number, as: N
  alias Lambdex.Church.Factorial, as: F

  test "it works" do
    assert 120 == 5 |> N.from_elixir() |> F.fact!().() |> N.to_elixir()
  end
end

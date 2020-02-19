defmodule Lambdex.ChurchFactorialTest do
  use ExUnit.Case

  alias Lambdex.ChurchNumber, as: N
  alias Lambdex.ChurchFactorial, as: F

  test "it works" do
    assert 120 == 5 |> N.from_elixir() |> F.fact!().() |> N.to_elixir()
  end
end

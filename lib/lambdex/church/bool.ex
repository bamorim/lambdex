defmodule Lambdex.Church.Bool do
  import Lambdex.Lang
  defl(true_, "t. f. t")
  defl(false_, "t. f. f")
  defl(not_, "b. b true_ false_")
  defl(and_, "a. b. a b false_")
  defl(nand_, "a. b. not_ (and_ a b)")

  def to_elixir(b), do: b.(true).(false)
  def from_elixir(true), do: true_()
  def from_elixir(false), do: false_()
end

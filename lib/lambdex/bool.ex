defmodule Lambdex.Bool do
  @moduledoc """
  Bool encoding (which is the same in either scott encoding and church encoding)
  """
  import Lambdex.Lang
  defl(:true!, "t. _. t")
  defl(:false!, "_. f. f")
  defl(:not, "b. b true! false!")
  defl(:and, "a. b. a b false!")
  # Lazy IF which expects a function instead of a value, since Elixir is eagerly evaluated
  defl(:ifte, "b. tf. ff. b tf ff b")
  defl(:nand, "a. b. not (and a b)")

  def to_elixir(b), do: b.(true).(false)
  def from_elixir(true), do: true!()
  def from_elixir(false), do: false!()
end

defmodule Lambdex.ChurchNumber do
  import Lambdex.Lang
  import Lambdex.Bool, only: [false!: 0, true!: 0]

  defl(:zero, "f. x. x")
  defl(:succ, "n. f. x. f (n f x)")
  defl(:add, "n. m. f. x. n f (m f x)")
  defl(:mul, "n. m. f. x. n (m f) x")
  # To be honest, I still don't quite understand it, so just trust Wikipedia
  defl(:pred, "n. f. x. n (g. h. h (g f)) (u. x) (u. u)")
  defl(:is_zero, "n. n (x. false) true")

  def to_elixir(n), do: n.(&(&1 + 1)).(0)

  def from_elixir(0), do: zero!()

  def from_elixir(num) when is_integer(num) and num > 0 do
    Enum.reduce(1..num, zero!(), fn _, acc -> succ!().(acc) end)
  end
end

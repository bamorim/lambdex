defmodule Lambdex.ScottNumber do
  import Lambdex.Lang
  import Lambdex.Recursion, only: [z: 0]
  import Lambdex.Bool, only: [false!: 0, true!: 0]

  defl(:zero, "_succ. zero. zero")
  defl(:succ, "n. succ. _zero. succ n")

  defl(:pred, "n. n (pred. pred) zero")

  defl(:add_h, "add. n. m. n (p. add p (succ. _zero. succ m)) m")
  defl(:add, "z add_h")

  defl(:do_mul_h, """
    do_mul. n. m. acc.
      n
        (np. do_mul np m (add m acc))
        acc
  """)

  defl(:do_mul, "z do_mul_h")

  defl(:mul, "n. m. do_mul n m zero")

  defl(:is_zero, "n. n (_. false!) true!")

  defl(:to_church_h, """
    to_church. n.
      n
        (p. f. x. f (to_church p f x))
        (_. x. x)
  """)

  defl(:to_church, "z to_church_h")

  def to_elixir(n) do
    n.(&(to_elixir(&1) + 1)).(0)
  end

  def from_elixir(0), do: zero()

  def from_elixir(num) when is_integer(num) and num > 0 do
    Enum.reduce(1..num, zero(), fn _, acc -> succ().(acc) end)
  end
end

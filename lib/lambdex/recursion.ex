defmodule Lambdex.Recursion do
  import Lambdex.Lang

  # Y Combinator doesn't work in strict-evaluated languages, so we have to use the Z-combinator
  defl(:z, "f. (x. (x x)) (x. (f (y. x x y)))")
end

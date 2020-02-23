defmodule Lambdex.ChurchFactorial do
  import Lambdex.Lang
  import Lambdex.Recursion, only: [z: 0]
  import Lambdex.ChurchNumber, only: [is_zero: 0, mul: 0, pred: 0]
  import Lambdex.Bool, only: [ifte: 0]

  #
  defl(:fact_h, "fact. n. ifte (is_zero n) (_. (f. x. f x)) (_. (mul n (fact (pred n))))")
  defl(:fact, "z fact_h")

  # This tecnically shouldn't be allowed in the language.
  # TODO: Think how to prevent this kind of behaviour

  defl(:fact_recursive, """
    n.
      ifte
      (is_zero n)
      (_. (f. x. f x))
      (_. (mul n (fact_recursive (pred n))))
  """)
end

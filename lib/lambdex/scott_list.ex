defmodule Lambdex.ScottList do
  import Lambdex.Lang
  import Lambdex.Recursion, only: [z!: 0]

  defl(nil, "nil. cons. nil")
  defl(:cons, "h. t. nil. cons. cons h t")

  defl(:map_h, """
    map. fun. l.
      l
        nil
        (h. t. cons (fun h) (map fun t))
  """)

  defl(:map, "z map_h")

  defl(:reduce, """
    fun. acc. l.
      l
        acc
        (h. t. reduce fun (fun acc h) t)
  """)

  def to_elixir(l), do: l.([]).(fn h -> fn t -> [h | to_elixir(t)] end end)

  def from_elixir(list) when is_list(list) do
    list
    |> Enum.reverse()
    |> Enum.reduce(nil!(), fn head, tail -> cons!().(head).(tail) end)
  end
end

defmodule Lambdex.Lang.Tokenizer do
  @type token :: :op | :cp | {:lam, atom()} | {:var, atom()}

  @spec tokenize(String.t()) :: [token()]
  def tokenize(x) when is_binary(x) do
    x
    |> String.replace(~r/[\(\)]/, &" #{&1} ")
    |> String.replace(".", ". ")
    |> String.split()
    |> Enum.map(fn
      "." ->
        raise "Unexpected token ."

      "(" ->
        :op

      ")" ->
        :cp

      other ->
        {
          if(String.ends_with?(other, "."), do: :lam, else: :var),
          other |> String.trim_trailing(".") |> String.to_atom()
        }
    end)
  end
end

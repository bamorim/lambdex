defmodule Lambdex.Lang do
  defmacro defl(name, expr) do
    ast = expr |> tokenize() |> parse()
    Lambdex.Lang.CodeGen.module_func(name, ast)
  end

  defdelegate tokenize(code), to: Lambdex.Lang.Tokenizer
  defdelegate parse(tokens), to: Lambdex.Lang.Parser
  defdelegate compile(ast), to: Lambdex.Lang.CodeGen
end

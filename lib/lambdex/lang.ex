defmodule Lambdex.Lang do
  alias Lambdex.Lang.{
    CodeGen,
    Parser,
    Tokenizer
  }

  defmacro mid(x) do
    IO.inspect(x)
    x
  end

  defmacro f(expr) do
    expr |> tokenize() |> parse() |> CodeGen.inline_func(__CALLER__)
  end

  defmacro defl(name, expr) do
    ast = expr |> tokenize() |> parse()
    CodeGen.module_func(name, ast)
  end

  defdelegate tokenize(code), to: Tokenizer
  defdelegate parse(tokens), to: Parser
  defdelegate compile(ast), to: CodeGen
end

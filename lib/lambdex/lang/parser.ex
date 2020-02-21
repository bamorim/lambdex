defmodule Lambdex.Lang.Parser do
  alias Lambdex.Lang.Tokenizer

  @type ast :: {:lam, atom(), ast()} | {:app, ast(), ast()} | {:var, atom()}
  @type parse_term :: {:var, atom()} | {:lam, atom(), [parse_term()]} | [parse_term()]
  @type parse_ctx :: {[Tokenizer.token()], [ast()]}

  @spec parse([Tokenizer.token()]) :: ast()
  def parse(tokens) do
    case parse_expr({tokens, [[]]}) do
      {[], [term]} ->
        to_ast(term)

      _ ->
        raise "Unexpected end due to unmatched closing parens"
    end
  end

  defp to_ast({:var, key}), do: {:var, key}
  defp to_ast({:lam, key, body}), do: {:lam, key, to_ast(body)}

  defp to_ast(expr) when is_list(expr) do
    expr
    |> Enum.map(&to_ast/1)
    |> Enum.reverse()
    |> case do
      [term] -> term
      [term | tail] -> Enum.reduce(tail, term, &{:app, &2, &1})
    end
  end

  def parse_expr({tokens, [expr | stack]}) do
    case parse_term({tokens, stack}) do
      {[], [term | stack]} ->
        {[], [[term | expr] | stack]}

      {[:cp | tokens], [term | stack]} ->
        {[:cp | tokens], [[term | expr] | stack]}

      {tokens, [term | stack]} ->
        parse_expr({tokens, [[term | expr] | stack]})
    end
  end

  @spec parse_term(parse_ctx()) :: parse_ctx()
  def parse_term({[{:var, key} | tokens], stack}) do
    {tokens, [{:var, key} | stack]}
  end

  def parse_term({[:op | tokens], stack}) do
    case parse_expr({tokens, [[] | stack]}) do
      {[:cp | tokens], stack} -> {tokens, stack}
      _ -> raise "Unexpected end due to unmatched open parens"
    end
  end

  def parse_term({[{:lam, key} | tokens], stack}) do
    {tokens, [body | stack]} = parse_expr({tokens, [[] | stack]})
    {tokens, [{:lam, key, body} | stack]}
  end
end

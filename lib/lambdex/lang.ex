defmodule Lambdex.Lang do
  @type ast :: {:lam, atom(), ast()} | {:app, ast(), ast()} | {:var, atom()}
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

  @spec parse([token()]) :: ast()
  def parse(tokens) do
    {tokens, []}
    |> parse_term()
    |> elem(1)
    |> List.first()
  end

  @type parse_ctx :: {[token()], [ast() | :start]}

  @spec parse_term(parse_ctx()) :: parse_ctx()
  def parse_term({[{:var, key} | tokens], asts}) do
    {tokens, [{:var, key} | asts]}
  end

  def parse_term({[:op | tokens], ast}) do
    {[:cp | tokens], ast} =
      {tokens, ast}
      |> parse_term()
      |> parse_app()

    {tokens, ast}
  end

  def parse_term({[{:lam, key} | tokens], asts}) do
    {tokens, [body | asts]} =
      {tokens, asts}
      |> parse_term()
      |> parse_app()

    {tokens, [{:lam, key, body} | asts]}
  end

  def parse_term(ctx), do: ctx

  def parse_app({[], _} = ctx), do: ctx

  def parse_app({[:cp | _], _} = ctx), do: ctx

  def parse_app({tokens, [fun | asts]}) do
    {tokens, [arg | asts]} = parse_term({tokens, asts})
    {tokens, [{:app, fun, arg} | asts]}
  end

  def parse_app(ctx), do: ctx
end

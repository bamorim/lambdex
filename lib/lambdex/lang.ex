defmodule Lambdex.Lang do
  defmacro defl(name, expr) do
    fun = expr |> tokenize() |> parse() |> compile()
    name = func_ref(name)

    quote do
      def unquote(name), do: unquote(fun)
    end
  end

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

  @type parse_term :: {:var, atom()} | {:lam, atom(), [parse_term()]} | [parse_term()]
  @type parse_ctx :: {[token()], [ast()]}

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

  @spec compile(ast()) :: Macro.t()
  def compile(ast), do: do_compile(ast, MapSet.new())

  @spec do_compile(ast(), MapSet.t()) :: Macro.t()
  def do_compile({:lam, key, body}, vars) do
    vars = MapSet.put(vars, key)

    quote do
      fn unquote(ref(key, vars)) ->
        unquote(do_compile(body, vars))
      end
    end
  end

  def do_compile({:var, key}, vars) do
    ref(key, vars)
  end

  def do_compile({:app, fun, arg}, vars) do
    quote do
      unquote(do_compile(fun, vars)).(unquote(do_compile(arg, vars)))
    end
  end

  defp ref(key, vars) do
    if MapSet.member?(vars, key) do
      arg_ref(key)
    else
      func_ref(key)
    end
  end

  def arg_ref(key), do: {:"lambdex_arg_#{key}", [], Elixir}
  def func_ref(nil), do: func_ref("nil")
  def func_ref(key), do: {:"#{key}!", [], []}
end

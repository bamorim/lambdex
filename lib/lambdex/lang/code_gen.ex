defmodule Lambdex.Lang.CodeGen do
  alias Lambdex.Lang.Parser

  def inline_func(ast, env) do
    vars = env.vars |> Keyword.keys() |> MapSet.new()

    compile(ast, vars)
  end

  def module_func(name, ast) do
    name = func_ref(name)
    fun = compile(ast)

    quote do
      def unquote(name), do: unquote(fun)
    end
  end

  @spec compile(Parser.ast(), MapSet.t()) :: Macro.t()
  def compile(ast, vars \\ MapSet.new()), do: do_compile(ast, vars)

  @spec do_compile(Parser.ast(), MapSet.t()) :: Macro.t()
  def do_compile({:lam, key, body}, vars) do
    vars = MapSet.put(vars, key)

    quote do
      fn unquote(arg_ref(key)) ->
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

  def arg_ref(key), do: {:"#{key}", [], nil}
  def func_ref(nil), do: func_ref("nil")
  def func_ref(key), do: {:"#{key}", [], []}
end

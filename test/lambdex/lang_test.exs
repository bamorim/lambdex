defmodule Lambdex.LangTest do
  use ExUnit.Case
  import Lambdex.Lang

  describe "tokenize/1" do
    test "unbound var" do
      assert [{:var, :a}] = tokenize("a")
    end

    test "identity" do
      assert [{:lam, :a}, {:var, :a}] = tokenize("a. a")
    end

    test "true" do
      assert [{:lam, :t}, {:lam, :f}, {:var, :t}] = tokenize("t. f. t")
    end

    test "false" do
      assert [{:lam, :t}, {:lam, :f}, {:var, :f}] = tokenize("t. f. f")
    end

    test "app" do
      assert [{:lam, :a}, {:lam, :b}, {:var, :a}, {:var, :b}] = tokenize("a. b. a b")
    end

    test "y combinator" do
      assert [
               {:lam, :f},
               :op,
               {:lam, :x},
               {:var, :f},
               :op,
               {:var, :x},
               {:var, :x},
               :cp,
               :cp,
               :op,
               {:lam, :x},
               {:var, :f},
               :op,
               {:var, :x},
               {:var, :x},
               :cp,
               :cp
             ] = tokenize("f. (x. f (x x)) (x. f (x x))")
    end
  end

  describe "parse/1" do
    test "unbound var" do
      assert {:var, :a} = parse([{:var, :a}])
    end

    test "identity" do
      assert {:lam, :a, {:var, :a}} = parse([{:lam, :a}, {:var, :a}])
    end

    test "true" do
      assert {
               :lam,
               :t,
               {
                 :lam,
                 :f,
                 {:var, :t}
               }
             } = parse([{:lam, :t}, {:lam, :f}, {:var, :t}])
    end

    test "app" do
      assert {
               :lam,
               :a,
               {
                 :lam,
                 :b,
                 {
                   :app,
                   {:var, :a},
                   {:var, :b}
                 }
               }
             } = parse([{:lam, :a}, {:lam, :b}, {:var, :a}, {:var, :b}])
    end

    test "y combinator" do
      assert {
               :lam,
               :f,
               {
                 :app,
                 {
                   :lam,
                   :x,
                   {
                     :app,
                     {:var, :f},
                     {
                       :app,
                       {:var, :x},
                       {:var, :x}
                     }
                   }
                 },
                 {
                   :lam,
                   :x,
                   {
                     :app,
                     {:var, :f},
                     {
                       :app,
                       {:var, :x},
                       {:var, :x}
                     }
                   }
                 }
               }
             } =
               parse([
                 {:lam, :f},
                 :op,
                 {:lam, :x},
                 {:var, :f},
                 :op,
                 {:var, :x},
                 {:var, :x},
                 :cp,
                 :cp,
                 :op,
                 {:lam, :x},
                 {:var, :f},
                 :op,
                 {:var, :x},
                 {:var, :x},
                 :cp,
                 :cp
               ])
    end
  end

  describe "integration" do
    test "app variations" do
      ast = "a. b. a b" |> tokenize() |> parse()

      variations = [
        "(a. (b. (a (b))))",
        "a. (b. (a (b)))",
        "(a. (b. (a b)))",
        "(a. (b. a (b)))",
        "(a. b. (a (b)))",
        "(a. (b. a b))",
        "a. b. (a b)",
        "(a. b. (a b))"
      ]

      for variation <- variations do
        assert ast == variation |> tokenize() |> parse()
      end
    end

    test "app should be left associative" do
      ast = "a. b. a a b" |> tokenize() |> parse()

      variations = [
        "a. b. ((a a) b)",
        "a. b. (a a) b"
      ]

      for variation <- variations do
        assert ast == variation |> tokenize() |> parse()
      end
    end

    test "unmatched open parentesis exception" do
      assert_raise(RuntimeError, ~r/unmatched open parens/, fn ->
        "a. (a" |> tokenize() |> parse()
      end)
    end

    test "unmatched closing parentesis exception" do
      assert_raise(RuntimeError, ~r/unmatched closing parens/, fn ->
        "a. a)" |> tokenize() |> parse()
      end)
    end
  end
end

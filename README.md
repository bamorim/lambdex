# Lambdex

This project is a playground where I'll explore some stuff related to lambda calculus while I'm attending [Recurse Center](https://recurse.com/).

This is also related to the talk I'm going to give at [NYC Elixir Meetup](https://www.meetup.com/NYC-Elixir/events/268594764/) and [CodeBEAM SF](https://codesync.global/conferences/code-beam-sf/).

The talks are going to focus more on the representation of data using only functions and some of the basics of lambda calculus.

I started by creating a simple language for representing lambda expressions just because typing `fn x -> ... end` for every lambda was too tyring, and typing `x. ...` or `x. (...)` is waaaay easier (and will fit on the screen when presenting).

## Notes for fast aliases when debugging

This is just me using this as a place to copy paste some code to ease my iEx sessions.

```elixir
alias Lambdex.Bool, as: B
alias Lambdex.ChurchNumber, as: CN
alias Lambdex.ScottNumber, as: SN
alias Lambdex.ScottList, as: SL
```
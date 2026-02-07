defmodule TextFSM.Template.State do
  @moduledoc """
  Represents a State in a TextFSM template.

  A State is a named collection of Rules. The Engine starts in the 'Start' state.
  Each line of input is matched against the rules in the current state.
  """
  @enforce_keys [:name, :rules]
  defstruct [:name, :rules]

  alias __MODULE__.Rule

  @type t() :: %__MODULE__{
          name: String.t(),
          rules: [Rule.t()]
        }

  import NimbleParsec

  whitespace = parsec({TextFSM.ParserHelpers, :whitespace})

  newline = parsec({TextFSM.ParserHelpers, :newline})

  state_name = parsec({TextFSM.ParserHelpers, :identifier})

  rule_line =
    concat(
      ignore(times(whitespace, 2)),
      parsec({__MODULE__.Rule, :rule})
    )

  rule_lines =
    repeat(
      concat(
        newline,
        rule_line
      )
    )

  defparsec(
    :state,
    concat(
      state_name |> unwrap_and_tag(:name),
      rule_lines |> tag(:rules)
    )
    |> post_traverse({:lift, []}),
    export_combinator: true
  )

  defp lift(rest, args, context, _position, _offset) do
    name = Keyword.get(args, :name)
    rules = Keyword.get(args, :rules)

    state = %__MODULE__{name: name, rules: rules}

    {rest, [state], context}
  end
end

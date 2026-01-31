defmodule TextFSM.Template do
  @enforce_keys [:value_definitions, :states]
  defstruct [:value_definitions, :states]

  alias __MODULE__.{ValueDefinition, State}

  @type t() :: %__MODULE__{
          value_definitions: [ValueDefinition.t()],
          states: [State.t()]
        }

  @spec value_names(t()) :: [String.t()]
  def value_names(%__MODULE__{value_definitions: value_definitions}) do
    value_definitions
    |> Enum.map(& &1.name)
  end

  import NimbleParsec

  newlines = parsec({TextFSM.ParserHelpers, :newlines})

  value_definition = parsec({ValueDefinition, :value_definition})

  state = parsec({State, :state})

  value_definitions =
    times(concat(value_definition, newlines), min: 1)

  states =
    times(concat(state, newlines), min: 1)

  defparsec(
    :template,
    concat(value_definitions, states)
    |> post_traverse({:lift, []})
  )

  defp lift(rest, args, context, _position, _offset) do
    {value_definitions, states} =
      Enum.split_with(
        args,
        fn
          %ValueDefinition{} ->
            true

          %State{} ->
            false
        end
      )

    template = %__MODULE__{
      value_definitions: value_definitions,
      states: states
    }

    {rest, [template], context}
  end
end

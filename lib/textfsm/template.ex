defmodule TextFSM.Template do
  @enforce_keys [:value_definitions, :states]
  defstruct [:value_definitions, :states]

  @type t() :: %__MODULE__{
          value_definitions: [__MODULE__.ValueDefinition.t()],
          states: [__MODULE__.State.t()]
        }

  import NimbleParsec

  newlines = parsec({TextFSM.ParserHelpers, :newlines})

  value_definition = parsec({__MODULE__.ValueDefinition, :value_definition})

  state = parsec({__MODULE__.State, :state})

  value_definitions =
    times(concat(value_definition, newlines), min: 1)

  states =
    times(concat(state, newlines), min: 1)

  defparsec(
    :template,
    concat(value_definitions, states)
  )
end

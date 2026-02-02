defmodule TextFSM.Template do
  @enforce_keys [:value_definitions, :states, :eof_state]
  defstruct [:value_definitions, :states, :eof_state]

  alias __MODULE__.{ValueDefinition, State}

  @type value_name() :: String.t()

  @type eof_state() :: :record | :no_record

  @type t() :: %__MODULE__{
          value_definitions: [ValueDefinition.t()],
          states: [State.t()],
          eof_state: eof_state()
        }

  @spec value_names(t()) :: [value_name()]
  def value_names(%__MODULE__{value_definitions: value_definitions}) do
    value_definitions
    |> Enum.map(& &1.name)
  end

  @spec value_name_to_definition_map(t()) :: %{value_name() => ValueDefinition.t()}
  def value_name_to_definition_map(%__MODULE__{value_definitions: value_definitions}) do
    Map.new(
      value_definitions,
      fn vd -> {vd.name, vd} end
    )
  end

  def get_rule(%__MODULE__{states: states}, state, idx) do
    case Enum.find(states, &(&1.name == state)) do
      nil ->
        nil

      %State{rules: rules} ->
        Enum.at(rules, idx)
    end
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
      states: states,
      eof_state: :record
    }

    {rest, [template], context}
  end
end

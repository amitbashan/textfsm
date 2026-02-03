defmodule TextFSM.Template do
  @enforce_keys [:value_definitions, :states, :eof_state]
  defstruct [:value_definitions, :states, :eof_state]

  alias __MODULE__.{ValueDefinition, State}
  alias State.Rule

  @type value_name() :: String.t()

  @type state_name() :: String.t()

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

  @spec get_rule(t(), state_name(), non_neg_integer()) :: nil | Rule.t()
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

    eof_state =
      if Enum.any?(states, &(&1.name == "EOF")) do
        :no_record
      else
        :record
      end

    template = %__MODULE__{
      value_definitions: value_definitions,
      states: states,
      eof_state: eof_state
    }

    {rest, [template], context}
  end
end

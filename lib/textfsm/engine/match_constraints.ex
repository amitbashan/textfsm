defmodule TextFSM.Engine.MatchConstraints do
  defstruct [:required_values, :key_values, :filldown_values, :fillup_values, :list_values]

  @type value_name() :: String.t()

  @type t() :: %__MODULE__{
          required_values: MapSet.t(value_name()),
          key_values: MapSet.t(value_name()),
          filldown_values: MapSet.t(value_name()),
          fillup_values: MapSet.t(value_name()),
          list_values: MapSet.t(value_name())
        }

  alias TextFSM.Template.ValueDefinition

  @spec new([ValueDefinition.t()]) :: t()
  def new(value_definitions) do
    {required_values, key_values, filldown_values, fillup_values, list_values} =
      Enum.reduce(
        value_definitions,
        {MapSet.new(), MapSet.new(), MapSet.new(), MapSet.new(), MapSet.new()},
        fn value_definition,
           {required_values, key_values, filldown_values, fillup_values, list_values} ->
          required_values = put_if_has_option(required_values, :required, value_definition)
          key_values = put_if_has_option(key_values, :key, value_definition)
          filldown_values = put_if_has_option(filldown_values, :filldown, value_definition)
          fillup_values = put_if_has_option(fillup_values, :fillup, value_definition)
          list_values = put_if_has_option(list_values, :list, value_definition)

          {required_values, key_values, filldown_values, fillup_values, list_values}
        end
      )

    %__MODULE__{
      required_values: required_values,
      key_values: key_values,
      filldown_values: filldown_values,
      fillup_values: fillup_values,
      list_values: list_values
    }
  end

  @spec required?(t(), value_name()) :: boolean()
  def required?(%__MODULE__{required_values: required_values}, value_name) do
    MapSet.member?(required_values, value_name)
  end

  @spec key?(t(), value_name()) :: boolean()
  def key?(%__MODULE__{key_values: key_values}, value_name) do
    MapSet.member?(key_values, value_name)
  end

  @spec filldown?(t(), value_name()) :: boolean()
  def filldown?(%__MODULE__{filldown_values: filldown_values}, value_name) do
    MapSet.member?(filldown_values, value_name)
  end

  @spec fillup?(t(), value_name()) :: boolean()
  def fillup?(%__MODULE__{fillup_values: fillup_values}, value_name) do
    MapSet.member?(fillup_values, value_name)
  end

  @spec list?(t(), value_name()) :: boolean()
  def list?(%__MODULE__{list_values: list_values}, value_name) do
    MapSet.member?(list_values, value_name)
  end

  defp put_if_has_option(map_set, option, value_definition) do
    if option in value_definition.options do
      MapSet.put(map_set, value_definition.name)
    else
      map_set
    end
  end
end

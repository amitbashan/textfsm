defmodule TextFSM.Template do
  @enforce_keys [:value_definitions, :states]
  defstruct [:value_definitions, :states]

  @type t() :: %__MODULE__{
          value_definitions: [__MODULE__.ValueDefinition.t()],
          states: [__MODULE__.State.t()]
        }
end

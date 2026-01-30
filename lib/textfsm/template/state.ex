defmodule TextFSM.Template.State do
  @enforce_keys [:name, :rules]
  defstruct [:name, :rules]

  @type t() :: %__MODULE__{
          name: String.t(),
          rules: [__MODULE__.Rule.t()]
        }
end

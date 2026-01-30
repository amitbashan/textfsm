defmodule TextFSM.Template.ValueDefinition do
  @enforce_keys [:name, :regex]
  defstruct [:name, :options, :regex]

  @type option() :: :filldown | :key | :required | :list | :fillup

  @type t() :: %__MODULE__{
          name: String.t(),
          options: [option()],
          regex: Regex.t()
        }
end

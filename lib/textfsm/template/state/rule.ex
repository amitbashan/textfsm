defmodule TextFSM.Template.State.Rule do
  @enforce_keys [:regex]
  defstruct [:regex, :action]

  @type t() :: %__MODULE__{
          regex: Regex.t(),
          action: __MODULE__.Action.t()
        }
end

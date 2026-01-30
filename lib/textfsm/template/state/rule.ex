defmodule TextFSM.Template.State.Rule do
  @enforce_keys [:regex]
  defstruct [:regex, :compiled_regex, :action]

  @type t() :: %__MODULE__{
          regex: String.t(),
          compiled_regex: Regex.t(),
          action: __MODULE__.Action.t()
        }
end

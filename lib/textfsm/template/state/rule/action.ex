defmodule TextFSM.Template.State.Rule.Action do
  @enforce_keys [:line_action, :record_action]
  defstruct line_action: :next, record_action: :no_record, next_state: nil

  @type line_action() :: :next | :continue

  @type record_action() :: :no_record | :record | :clear | :clear_all

  @type t() :: %__MODULE__{
          line_action: line_action(),
          record_action: record_action(),
          next_state: String.t()
        }
end

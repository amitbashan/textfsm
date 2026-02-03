defmodule TextFSM.Engine.Context do
  defstruct current_state: "Start", current_rule_idx: 0, current_line_idx: 0

  @type t() :: %__MODULE__{
          current_state: String.t(),
          current_rule_idx: non_neg_integer(),
          current_line_idx: non_neg_integer()
        }

  @type next_state() :: nil | String.t()

  @spec next(t(), next_state()) :: t()
  def next(
        %__MODULE__{current_state: current_state, current_line_idx: current_line_idx} = context,
        new_state \\ nil
      ) do
    %{
      context
      | current_state: new_state || current_state,
        current_rule_idx: 0,
        current_line_idx: current_line_idx + 1
    }
  end

  @spec skip_rule(t()) :: t()
  def skip_rule(%__MODULE__{current_rule_idx: current_rule_idx} = context) do
    %{context | current_rule_idx: current_rule_idx + 1}
  end
end

defmodule TextFSM.Engine do
  @moduledoc """
  The Engine is responsible for executing the TextFSM state machine against input text.

  It maintains the current state (context), the accumulated data (memory), and the template rules.
  The engine processes text line by line, matching against the rules of the current state,
  and executing corresponding actions (recording data, transitioning states, etc.).
  """
  alias TextFSM.Error
  alias __MODULE__.{Context, Memory}
  alias TextFSM.Template
  alias Template.State
  alias State.Rule
  alias Rule.{Action, ErrorAction}

  defstruct [:context, :memory, :template, :lines]

  @type value_name() :: String.t()

  @type value() :: nil | String.t() | [String.t()]

  @type table() :: %{value_name() => [value()]}

  @type t() :: %__MODULE__{
          context: Context.t(),
          memory: Memory.t(),
          template: Template.t(),
          lines: [String.t()]
        }

  @doc """
  Creates a new Engine instance.

  Initializes the engine with the compiled template and the input text.

  ## Parameters

  * `template` - The compiled `TextFSM.Template`.
  * `text` - The input text string.

  ## Returns

  * `TextFSM.Engine.t()`
  """
  @spec new(Template.t(), String.t()) :: t()
  def new(%Template{value_definitions: value_definitions} = template, text) do
    %__MODULE__{
      context: %Context{},
      memory: Memory.new(value_definitions),
      template: template,
      lines: String.split(text, "\n")
    }
  end

  @doc """
  Runs the engine until completion.

  It steps through the state machine processing lines until it halts (End state or EOF).
  Finally, it returns the parsed data as a column-oriented table represented as a map from value names to columns.

  ## Parameters

  * `engine` - The initialized `TextFSM.Engine` struct.

  ## Returns

  * `table()` - The parsed data as a map of value names to lists of values (columns).
  """
  @spec run(t()) :: table()
  def run(%__MODULE__{} = engine) do
    case step(engine) do
      {:halt, engine} -> finalize(engine)
      {:cont, engine} -> run(engine)
    end
  end

  defp step(%__MODULE__{context: context} = engine) do
    rule = fetch_rule(engine)
    line = fetch_line(engine)

    cond do
      is_nil(line) ->
        {:halt, execute_eof_state(engine)}

      is_nil(rule) ->
        engine |> next() |> step()

      true ->
        case match_rule(engine, rule, line) do
          :no_match ->
            engine
            |> skip_rule()
            |> step()

          {:match, memory} ->
            next_state = rule.action.next_state

            context =
              case rule.action.line_action do
                :next -> Context.next(context, next_state)
                :continue -> Context.skip_rule(context)
              end

            engine = %{engine | context: context, memory: memory}

            {(next_state == "End" && :halt) || :cont, engine}
        end
    end
  end

  defp execute_eof_state(
         %__MODULE__{template: %Template{eof_state: eof_state}, memory: memory} = engine
       ) do
    memory =
      case eof_state do
        :record -> Memory.record(memory, true)
        :no_record -> memory
      end

    %{engine | memory: memory}
  end

  defp match_rule(
         %__MODULE__{memory: memory},
         %Rule{
           compiled_regex: %Regex{} = regex,
           action: %Action{record_action: record_action}
         },
         line
       ) do
    matches = Regex.named_captures(regex, line)

    if is_nil(matches) do
      :no_match
    else
      memory =
        Enum.reduce(matches, memory, fn {value_name, match}, acc ->
          Memory.collect(acc, value_name, match)
        end)

      memory =
        case record_action do
          :no_record ->
            memory

          :record ->
            Memory.record(memory)

          :clear ->
            Memory.clear(memory)

          :clear_all ->
            Memory.clear_all(memory)
        end

      {:match, memory}
    end
  end

  defp match_rule(
         %__MODULE__{},
         %Rule{action: %ErrorAction{message: message}, compiled_regex: %Regex{} = regex},
         line
       ) do
    if Regex.match?(regex, line) do
      raise Error, message: message
    else
      :no_match
    end
  end

  defp fetch_rule(%__MODULE__{
         context: %Context{
           current_state: current_state,
           current_rule_idx: current_rule_idx
         },
         template: template
       }) do
    Template.get_rule(template, current_state, current_rule_idx)
  end

  defp fetch_line(%__MODULE__{
         context: %Context{current_line_idx: current_line_idx},
         lines: lines
       }) do
    Enum.at(lines, current_line_idx)
  end

  defp next(%__MODULE__{context: context} = engine) do
    %{engine | context: Context.next(context)}
  end

  defp skip_rule(%__MODULE__{context: context} = engine) do
    %{engine | context: Context.skip_rule(context)}
  end

  defp finalize(%__MODULE__{memory: memory}) do
    Memory.finalize(memory)
  end
end

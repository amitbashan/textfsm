defmodule TextFSM do
  alias __MODULE__.{Template, Engine}

  @type byte_offset() :: non_neg_integer()

  @type line() :: {pos_integer(), byte_offset}

  @type rest() :: binary()

  @type reason() :: String.t()

  @type context() :: map()

  @type parse_error() :: {:error, reason(), rest(), context(), line(), byte_offset()}

  @type error_message() :: String.t()

  @type validation_error() :: {:error, [error_message()]}

  @type error() :: parse_error() | validation_error()

  @type value_name() :: String.t()

  @type value() :: nil | String.t() | [String.t()]

  @type table() :: %{value_name() => [value()]}

  @spec parse_template(binary()) :: {:ok, Template.t()} | error()
  def parse_template(template) do
    with {:ok, [template], _, _, _, _} <- Template.template(template),
         :ok <- Template.Validator.validate(template) do
      {:ok, template |> Template.Compiler.compile()}
    else
      {:error, reason, rest, context, line, byte_offset} ->
        {:error, reason, rest, context, line, byte_offset}

      validation_errors ->
        validation_errors
    end
  end

  @spec parse(binary(), binary()) :: {:ok, table()} | error()
  def parse(template, text) do
    with {:ok, template} <- parse_template(template),
         engine = Engine.new(template, text) do
      {:ok, Engine.run(engine)}
    else
      errors -> errors
    end
  end
end

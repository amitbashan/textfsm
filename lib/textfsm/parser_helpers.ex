defmodule TextFSM.ParserHelpers do
  import NimbleParsec

  defcombinator(
    :state_name,
    concat(
      ascii_string([?A..?Z], min: 1),
      ascii_string([?A..?Z, ?a..?z, ?0..?9], min: 0)
    )
    |> reduce({Enum, :join, []})
  )
end

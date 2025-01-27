defmodule ExEmail.Parser do
  @moduledoc false

  use AbnfParsec,
    abnf_file: "priv/parser/rfc5321.abnf",
    parse: :mailbox
end

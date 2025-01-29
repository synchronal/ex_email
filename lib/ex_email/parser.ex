defmodule ExEmail.Parser do
  @moduledoc false

  @external_resource "priv/parser/rfc5321.abnf"

  use AbnfParsec,
    abnf_file: "priv/parser/rfc5321.abnf",
    parse: :mailbox
end

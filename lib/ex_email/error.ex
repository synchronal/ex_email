defmodule ExEmail.Error do
  @type t() :: %__MODULE__{
          address: String.t(),
          message: String.t()
        }

  defexception [:address, :message]

  def new(msg, address) when is_binary(msg),
    do: __struct__(address: address, message: msg)
end

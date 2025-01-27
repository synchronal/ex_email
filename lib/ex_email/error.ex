defmodule ExEmail.Error do
  defexception [:address, :message]

  def new(msg, address) when is_binary(msg),
    do: __struct__(address: address, message: msg)
end

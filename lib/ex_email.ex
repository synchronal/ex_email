defmodule ExEmail do
  @moduledoc """
  A pure-Elixir reimplementation of `:email_validator`.
  """

  alias ExEmail.Error

  @max_domain 255
  @max_local 64
  @max_length @max_domain + @max_local + 1

  @type t() :: {String.t(), String.t()}

  @spec validate(String.t()) :: :ok | {:error, Error.t()}
  def validate(address) do
    case parse(address) do
      {:ok, _} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  @spec parse(String.t()) :: {:ok, t()} | {:error, Error.t()}
  def parse(address) when is_binary(address) do
    case parse_address(address) do
      {:ok, result} -> {:ok, result}
      {:error, msg} -> {:error, Error.new(msg, address)}
    end
  end

  # # #

  defp parse_address(address) when byte_size(address) <= @max_length do
    with {:ok, {local, domain}} <- parse_mailbox(address),
         {:ok, local} <- parse_local(local),
         {:ok, domain} <- parse_domain(domain) do
      {:ok, {local, domain}}
    end
  end

  defp parse_address(address),
    do: {:error, Error.new("address too large", address)}

  defp parse_mailbox(address) do
    case ExEmail.Parser.mailbox(address) do
      {:ok, [mailbox: [{:local_part, local}, "@", {:domain, domain}]], "", _, _, _} ->
        {:ok, {local, domain}}

      {:ok, _, remainder, _, _, _} ->
        {:error, "email contains invalid remainder \"#{remainder}\""}

      {:error, error, "", _, _, _} ->
        {:error, error}

      {:error, _error, _remainder, _, _, _} = _res ->
        {:error, "parse error"}
    end
  end

  defp parse_domain([{_, parts}]) do
    parts
    |> flatten()
    |> :erlang.list_to_binary()
    |> parse_domain()
  end

  defp parse_domain(domain) when is_binary(domain) and byte_size(domain) <= @max_domain, do: {:ok, domain}
  defp parse_domain(domain) when is_binary(domain), do: {:error, "domain part is too large"}

  defp parse_local([{_, local}]) do
    local
    |> flatten()
    |> :erlang.list_to_binary()
    |> parse_local()
  end

  defp parse_local(local) when is_binary(local) and byte_size(local) <= @max_local, do: {:ok, local}
  defp parse_local(local) when is_binary(local), do: {:error, "local part is too large"}

  defp flatten({_, value}) when is_list(value), do: flatten(value)
  defp flatten(value) when is_binary(value), do: value
  defp flatten(value) when is_number(value), do: value
  defp flatten(values) when is_list(values), do: for(value <- values, do: flatten(value))
end

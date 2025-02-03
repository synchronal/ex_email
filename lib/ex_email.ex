defmodule ExEmail do
  @moduledoc """
  `ExEmail` implements a parser and validator for email addresses according to the
  ABNF rules defined in the following RFCs:

  - [RFC5321 - Simple Mail Transfer Protocol](https://tools.ietf.org/rfc/rfc5321.txt)
  - [RFC6531 - SMTP Extension for Internationalized](https://tools.ietf.org/rfc/rfc6531.txt)
  - [RFC6532 - Internationalized Email Headers](https://tools.ietf.org/rfc/rfc6532.txt)

  When parsing emails addressed to IP addresses, the domain part is parsed via the rules
  defined in
  [RFC3986: Uniform Resource Identifier (URI): Generic Syntax](https://tools.ietf.org/rfc/rfc3986.txt).

  ## Notes

  - `ExEmail` is a reimplementation of [`:email_validator`](https://hex.pm/packages/email_validator)
    in Elixir. It's a fantastic library.
  - ABNF rules are compiled using `AbnfParsec`. Because it's built on top of `NimbleParsec`,
    the ABNF shipped with this library differs from the relevant RFCs in specific ways. ABNF
    assumes that when a rule defines multiple choices, that each choice can be attempted, and
    then backtracked to the last matching rule; `NimbleParsec` does not support backtracking,
    so rules must be defined such that the most appropriate rule is most likely to be matched
    first.
  """

  alias ExEmail.Error

  @max_domain 255
  @max_local 64
  @max_length @max_domain + @max_local + 1

  @typedoc """
  A tuple of the local and domain parts of an email address; parsing the address
  `alice@example.com` returns `{"alice", "example.com"}`.
  """
  @type t() :: {local_part(), domain_part()}
  @type local_part() :: String.t()
  @type domain_part() :: String.t()

  @doc """
  Validates the format of an email address, returning either `:ok` or a
  tuple of `{:error, ExEmail.Error.t()}`.

  ## Examples

  ``` elixir
  iex> ExEmail.validate("a@example.com")
  :ok

  iex> ExEmail.validate("@example.com")
  {:error, ExEmail.Error.new("parse error", "@example.com")}
  ```
  """
  @spec validate(String.t()) :: :ok | {:error, Error.t()}
  def validate(address) do
    case parse(address) do
      {:ok, _} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Parses an email address into a tuple of `{:ok, {local_part, domain_part}}`, or
  `{:error, ExEmail.Error.t()}`.

  ## Examples

  ``` elixir
  iex> ExEmail.parse("a@example.com")
  {:ok, {"a", "example.com"}}

  iex> ExEmail.parse("@example.com")
  {:error, ExEmail.Error.new("parse error", "@example.com")}
  ```
  """
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

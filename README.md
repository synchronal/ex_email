# ExEmail

Helpers for parsing and validating email addresses.

## Usage

Add `ExEmail` to your mix project deps:

``` elixir
{:ex_email, "~> 0.1"}
```

An email address may be parsed into its local and domain parts via
`ExEmail.parse/1`:

``` elixir
iex> ExEmail.parse("alice@example.com")
{:ok, {"alice", "example.com"}}
iex> ExEmail.parse("@example.com")
{:error, ExEmail.Error.new("parse error", "@example.com")}
```

If the values of the parts are not important, just the validity of the
address, then `ExEmail.validate/1` may be used:

``` elixir
iex> ExEmail.validate("alice@example.com")
:ok
iex> ExEmail.validate("@example.com")
{:error, ExEmail.Error.new("parse error", "@example.com")}
```

## References

This library pulls heavily from the
[email_validator](https://github.com/rbkmoney/email_validator) Erlang
library, which is great but no longer seems to be maintained.

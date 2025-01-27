defmodule ExEmailTest do
  use ExUnit.Case
  alias ExEmail.Error

  doctest ExEmail

  @simple_addresses [
    {"simple@example.com", {"simple", "example.com"}},
    {"very.common@example.com", {"very.common", "example.com"}},
    {"disposable.style.email.with+symbol@example.com", {"disposable.style.email.with+symbol", "example.com"}},
    {"other.email-with-hyphen@example.com", {"other.email-with-hyphen", "example.com"}},
    {"fully-qualified-domain@example.com", {"fully-qualified-domain", "example.com"}},
    {"user.name+tag+sorting@example.com", {"user.name+tag+sorting", "example.com"}},
    {"x@example.com", {"x", "example.com"}},
    {"example-indeed@strange-example.com", {"example-indeed", "strange-example.com"}},
    {"admin@mailserver1", {"admin", "mailserver1"}},
    {"example@s.example", {"example", "s.example"}},
    {~S|" "@example.org|, {~s|" "|, "example.org"}},
    {"\"john..doe\"@example.org", {~s|"john..doe"|, "example.org"}},
    {"mailhost!username@example.org", {"mailhost!username", "example.org"}},
    {"user%example.com@example.org", {"user%example.com", "example.org"}}
  ]

  describe "parse" do
    test "handles simple emails" do
      for {address, expected} <- @simple_addresses do
        parsed = ExEmail.parse(address)

        assert parsed == {:ok, expected}, """
        Expected address #{address} parse:

        Expected: {:ok, #{inspect(expected)}}
        Found:    #{inspect(parsed)}
        """
      end
    end

    test "returns an error when invalid" do
      assert {:error, %Error{message: ~s|expected string "@"|}} = ExEmail.parse("x")
      assert {:error, %Error{message: ~s|expected string "@"|}} = ExEmail.parse("abc.example.com")

      assert {:error, %Error{message: ~s|email contains invalid remainder "@c@example.com"|}} =
               ExEmail.parse("a@b@c@example.com")

      assert {:error, %Error{message: ~s|parse error|}} = ExEmail.parse(~s|a"b(c)d,e:f;g<h>i[j\k]l@example.com|)
    end

    test "returns an error when the local part is greater than 64 characters" do
      assert {:error, %Error{message: "local part is too large"}} =
               ExEmail.parse("1234567890123456789012345678901234567890123456789012345678901234x@example.com")
    end
  end

  # describe "validate" do
  #   test "validates simple email addresses" do
  #     for address <- @simple_addresses do
  #       assert ExEmail.validate(address) == :ok, "Expected address #{address} to be valid"
  #     end
  #   end
  # end
end

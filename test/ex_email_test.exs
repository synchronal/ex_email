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

  @special_characters [
    {"\"ab\\c\"@example.com", {~s|"ab\\c"|, "example.com"}},
    {"\"Abc@def\"@example.com", {~s|"Abc@def"|, "example.com"}},
    {"\"Fred Bloggs\"@example.com", {~s|"Fred Bloggs"|, "example.com"}},
    {"customer/department=shipping@example.com", {~s|customer/department=shipping|, "example.com"}},
    {"$A12345@example.com", {~s|$A12345|, "example.com"}},
    {"!def!xyz%abc@example.com", {~s|!def!xyz%abc|, "example.com"}},
    {"_somename@example.com", {~s|_somename|, "example.com"}}
  ]

  @ip_addresses [
    {"ip@[127.0.0.1]", {"ip", "[127.0.0.1]"}},
    {"ip@[IPv6:::1]", {"ip", "[IPv6:::1]"}},
    {"ip@[IPv6:::127.0.0.127]", {"ip", "[IPv6:::127.0.0.127]"}}
    # {"ip@[IPv6:dead::beef]", {"ip", "[IPv6:dead::beef]"}},
    # {"ip@[IPv6:dead::]", {"ip", "[IPv6:dead::]"}},
    # {"ip@[IPv6:dead:beef::7.0.0.1]", {"ip", "[IPv6:dead:beef::7.0.0.1]"}},
    # {"ip@[IPv6:d:e:a:d:be:ef:7.0.0.3]", {"ip", "[IPv6:d:e:a:d:be:ef:7.0.0.3]"}},
    # {"ip@[IPv6:2001:0db8:85a3:0000:0000:8a2e:0370:7334]", {"ip", "[IPv6:2001:0db8:85a3:0000:0000:8a2e:0370:7334]"}}
  ]

  @utf8_addresses [
    # {"öö@example.com", {"öö", "example.com"}},
    # {"испытание@пример.рф", {"испытание", "пример.рф"}},
    # {"我買@屋企.香港", {"我買", "屋企.香港"}},
    # {"संपर्क@डाटामेल.भारत", {"संपर्क", "डाटामेल.भारत"}}
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

    test "handles special characters" do
      for {address, expected} <- @special_characters do
        parsed = ExEmail.parse(address)

        assert parsed == {:ok, expected}, """
        Expected address #{address} parse:

        Expected: {:ok, #{inspect(expected)}}
        Found:    #{inspect(parsed)}
        """
      end
    end

    test "handles ipv4 and ipv6 addresses" do
      for {address, expected} <- @ip_addresses do
        parsed = ExEmail.parse(address)

        assert parsed == {:ok, expected}, """
        Expected address #{address} parse:

        Expected: {:ok, #{inspect(expected)}}
        Found:    #{inspect(parsed)}
        """
      end
    end

    test "handles utf8" do
      for {address, expected} <- @utf8_addresses do
        parsed = ExEmail.parse(address)

        assert parsed == {:ok, expected}, """
        Expected address #{address} parse:

        Expected: {:ok, #{inspect(expected)}}
        Found:    #{inspect(parsed)}
        """
      end
    end

    test "returns an error when invalid format" do
      assert {:error, %Error{message: ~s|expected string "@"|}} = ExEmail.parse("x")
      assert {:error, %Error{message: ~s|expected string "@"|}} = ExEmail.parse("abc.example.com")
      assert {:error, %Error{message: ~s|parse error|}} = ExEmail.parse("@example.com")
      assert {:error, %Error{message: ~s|expected string| <> _}} = ExEmail.parse("abc@")

      assert {:error, %Error{message: ~s|email contains invalid remainder "@c@example.com"|}} =
               ExEmail.parse("a@b@c@example.com")

      assert {:error, %Error{message: ~s|parse error|}} = ExEmail.parse(~s|a"b(c)d,e:f;g<h>i[j\k]l@example.com|)
      assert {:error, %Error{message: ~s|parse error|}} = ExEmail.parse("just\"not\"right@example.com")
      assert {:error, %Error{message: ~s|parse error|}} = ExEmail.parse("this is\"not\\allowed@example.com")
      assert {:error, %Error{message: ~s|parse error|}} = ExEmail.parse("this\\ still\\\"not\\allowed@example.com")
    end

    test "returns an error when the local part is greater than 64 characters" do
      assert {:error, %Error{message: "local part is too large"}} =
               ExEmail.parse("1234567890123456789012345678901234567890123456789012345678901234x@example.com")
    end

    test "returns an error when the domain part is greater than 255 characters" do
      assert {:error, %Error{message: "domain part is too large"}} =
               ExEmail.parse("abc@#{String.pad_leading("", 255 - 3, "a")}.com")

      assert {:ok, _} =
               ExEmail.parse("abc@#{String.pad_leading("", 255 - 4, "a")}.com")
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

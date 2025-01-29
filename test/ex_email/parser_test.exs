defmodule ExEmail.ParserTest do
  use ExUnit.Case, async: true
  alias ExEmail.Parser

  describe "local_part" do
    test "alpha" do
      assert {:ok, [local_part: [dot_string: [atom: [atext: ~c"a"]]]], "", %{}, {1, 0}, 1} =
               Parser.local_part("a")
    end

    test "alphanumeric" do
      assert {:ok,
              [
                local_part: [
                  dot_string: [
                    atom: [
                      atext: ~c"n",
                      atext: ~c"a",
                      atext: ~c"m",
                      atext: ~c"e",
                      atext: ~c"1",
                      atext: ~c"2",
                      atext: ~c"3",
                      atext: ~c"4"
                    ]
                  ]
                ]
              ], "", %{}, {1, 0},
              8} =
               Parser.local_part("name1234")
    end

    @tag :skip
    test "utf8" do
      assert {:ok, [local_part: [dot_string: [atom: [atext: ~c"ö", atext: ~c"ö"]]]], "", %{}, {1, 0}, 2} =
               Parser.local_part("öö")
    end
  end
end

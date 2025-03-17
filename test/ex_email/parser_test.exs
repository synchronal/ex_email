defmodule ExEmail.ParserTest do
  use ExUnit.Case, async: true
  alias ExEmail.Parser

  describe "local_part" do
    test "alpha" do
      assert {:ok, [local_part: [dot_string: [atom: [atext: ["a"]]]]], "", %{}, {1, 0}, 1} =
               Parser.local_part("a")
    end

    test "alphanumeric" do
      assert {:ok,
              [
                local_part: [
                  dot_string: [
                    atom: [
                      atext: ["n"],
                      atext: ["a"],
                      atext: ["m"],
                      atext: ["e"],
                      atext: ["1"],
                      atext: ["2"],
                      atext: ["3"],
                      atext: ["4"]
                    ]
                  ]
                ]
              ], "", %{}, {1, 0},
              8} =
               Parser.local_part("name1234")
    end

    test "utf8" do
      assert {:ok,
              [
                local_part: [
                  dot_string: [
                    atom: [
                      atext: [{:utf8_non_ascii, [utf8_2: [195, {:utf8_tail, [182]}]]}],
                      atext: [{:utf8_non_ascii, [utf8_2: [195, {:utf8_tail, [182]}]]}]
                    ]
                  ]
                ]
              ], "", %{}, {1, 0},
              4} =
               Parser.local_part("öö")
    end
  end
end

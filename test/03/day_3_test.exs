defmodule BagContentsMachine do
  @moduledoc """
  This module find the priorities of items in elf bags in 2 different ways:

  First it is able to divide the bag in to two parts and figure out what items are carried
  in both pockets of a bag

  Secondly it is able to find the badge item (an item shared by groups of 3 elfs)
  in each bag and calculate a priority score sum from them
  """

  @doc """
  gets the total priority of all items elfs are carrying that they have in both
  pockets of their backpack
  """
  def get_priority_score_of_wrongly_placed_items(items_string) do
    items_string
    |> divide_items_between_elves()
    |> divide_pockets_in_bag()
    |> get_double_items()
    |> items_to_priority()
    |> Enum.sum()

    # get items from bag 1 that are also in bag 2
    # map items to priorities
    # sum priorities
  end

  @doc """
  finds the group badges of elves and calculates a total sum with each group's type
  of badge.
  """
  def get_priority_of_group_badges(items_string) do
    items_string
    |> divide_items_between_elves()
    |> group_every_three_elves()
    |> find_badge_in_group()
    |> items_to_priority()
    |> Enum.sum()
  end

  # items in both bag pocket methods
  defp divide_pockets_in_bag(all_contents) do
    all_contents
    |> Enum.map(fn contents ->
      length = String.length(contents)
      half_length = (length / 2) |> trunc()
      contents |> String.codepoints() |> Enum.chunk_every(half_length) |> Enum.map(&Enum.join/1)
    end)
  end

  defp get_double_items(divided_contents) do
    divided_contents
    |> Enum.map(fn [a, b] ->
      a
      |> String.codepoints()
      |> Enum.find(fn item -> String.contains?(b, item) end)
    end)
  end

  # Badge methods
  defp group_every_three_elves(all_contents) do
    all_contents
    |> Enum.chunk_every(3)
  end

  defp find_badge_in_group(groups) do
    groups
    |> Enum.map(fn [elf1, elf2, elf3] ->
      elf1
      |> String.codepoints()
      |> Enum.find(fn item -> String.contains?(elf2, item) && String.contains?(elf3, item) end)
    end)
  end

  # Shared methods
  defp divide_items_between_elves(items_string) do
    items_string
    |> String.split("\n")
    |> Enum.reject(fn item -> item == "" end)
  end

  defp items_to_priority(duplicate_sets) do
    duplicate_sets
    |> Enum.map(fn item -> item |> get_priority_of_letter() end)
  end

  defp get_priority_of_letter(letter) do
    case(letter) do
      "a" -> 1
      "b" -> 2
      "c" -> 3
      "d" -> 4
      "e" -> 5
      "f" -> 6
      "g" -> 7
      "h" -> 8
      "i" -> 9
      "j" -> 10
      "k" -> 11
      "l" -> 12
      "m" -> 13
      "n" -> 14
      "o" -> 15
      "p" -> 16
      "q" -> 17
      "r" -> 18
      "s" -> 19
      "t" -> 20
      "u" -> 21
      "v" -> 22
      "w" -> 23
      "x" -> 24
      "y" -> 25
      "z" -> 26
      "A" -> 27
      "B" -> 28
      "C" -> 29
      "D" -> 30
      "E" -> 31
      "F" -> 32
      "G" -> 33
      "H" -> 34
      "I" -> 35
      "J" -> 36
      "K" -> 37
      "L" -> 38
      "M" -> 39
      "N" -> 40
      "O" -> 41
      "P" -> 42
      "Q" -> 43
      "R" -> 44
      "S" -> 45
      "T" -> 46
      "U" -> 47
      "V" -> 48
      "W" -> 49
      "X" -> 50
      "Y" -> 51
      "Z" -> 52
    end
  end
end

defmodule Day3Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/3
  """

  def read_test do
    """
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
    """
  end

  def read_fixture do
    File.read!("test/03/fixture/bag_contents.txt")
  end

  test "Puzzle 1: Read the sum of items carried in both pockets in each elf bag" do
    test_contents = read_test()

    test_result = BagContentsMachine.get_priority_score_of_wrongly_placed_items(test_contents)
    assert test_result == 157

    real_contents = read_fixture()
    real_result = BagContentsMachine.get_priority_score_of_wrongly_placed_items(real_contents)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: Find the sum of priorities of badges carried by elf groups" do
    test_contents = read_test()

    test_result = BagContentsMachine.get_priority_of_group_badges(test_contents)
    assert test_result == 70

    real_contents = read_fixture()
    real_result = BagContentsMachine.get_priority_of_group_badges(real_contents)
    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

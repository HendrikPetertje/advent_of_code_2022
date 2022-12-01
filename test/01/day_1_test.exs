defmodule ElfCalories do
  @moduledoc """
  This module gets the calories of different elves from a stringed list of snacks per elf
  the divider between elves is a double newline ("\\n\\n").
  the divider betwen snacks is a single newline ("\n").
  """

  @doc """
  Return total calories of snacks for single elf with the most when providing a list
  """
  # @spec calories_of_elf_with_most_calories(string) :: number
  def calories_of_elf_with_most_calories(list) do
    list
    |> split_per_elf()
    |> map_to_elves_with_total_calories()
    # Get single value with higest value through reducer
    |> Enum.reduce(&max/2)
  end

  @doc """
  Return total calories of snacks for 3 elves with the most when providing a list
  """
  # @spec total_calories_by_3_elves_with_most_calories(string) :: number
  def total_calories_by_3_elves_with_most_calories(list) do
    list
    |> split_per_elf()
    |> map_to_elves_with_total_calories()
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp split_per_elf(list) do
    String.split(list, "\n\n")
  end

  defp map_to_elves_with_total_calories(lists_per_elf) do
    lists_per_elf
    |> Enum.map(fn string_collection ->
      string_collection
      # Split per newline
      |> String.split("\n")
      # remove empty string from last newline
      |> Enum.reject(fn value -> value == "" end)
      # Turn to integers
      |> Enum.map(fn string_value -> String.to_integer(string_value) end)
      # Perform a total sum
      |> Enum.sum()
    end)
  end
end

defmodule Day1Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/1
  """

  def read_test do
    """
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
    """
  end

  def read_fixture do
    File.read!("test/01/fixture/elf_list.txt")
  end

  test "Puzzle 1: elf calories and elf number of elf with highest calories" do
    elf_list = read_test()

    result = ElfCalories.calories_of_elf_with_most_calories(elf_list)
    assert result == 24000

    real_elf_list = read_fixture()
    real_result = ElfCalories.calories_of_elf_with_most_calories(real_elf_list)

    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: total sum of 3 elves with most calories" do
    elf_list = read_test()

    result = ElfCalories.total_calories_by_3_elves_with_most_calories(elf_list)
    assert result == 45000

    real_elf_list = read_fixture()
    real_result = ElfCalories.total_calories_by_3_elves_with_most_calories(real_elf_list)

    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

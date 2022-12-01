defmodule ElfCalories do
  def elf_no_with_most_calories(list) do
    list
    |> split_per_elf()
    |> map_to_elf_with_total_calories()
    # Get single value with higest value through reducer
    |> Enum.reduce(&max/2)
  end

  def total_calories_by_3_richest_elves(list) do
    list
    |> split_per_elf()
    |> map_to_elf_with_total_calories()
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp split_per_elf(list) do
    String.split(list, "\n\n")
  end

  defp map_to_elf_with_total_calories(lists_per_elf) do
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

    result = ElfCalories.elf_no_with_most_calories(elf_list)
    assert result == 24000

    real_elf_list = read_fixture()
    real_result = ElfCalories.elf_no_with_most_calories(real_elf_list)

    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: total sum of 3 elves with most calories" do
    elf_list = read_test()

    result = ElfCalories.total_calories_by_3_richest_elves(elf_list)
    assert result == 45000

    real_elf_list = read_fixture()
    real_result = ElfCalories.total_calories_by_3_richest_elves(real_elf_list)

    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

defmodule CleanUpCampDebugger do
  @moduledoc """
  the Elves have made a mess. they have decdied to start cleaning the place up
  and they want to do so in groups of 2, but it turns out that they have made
  a mess of their planning again. some elves are cleaning each other's areas up

  The first method here checks if one of the elves work is completely obsolete
  (the other elf is taking care all their areas already) while the second one
  counts the number of elves that have any overlap at all.
  """

  @doc """
  Checks if one elf has been assigned to do all the work of the other elf in
  the couple.
  expects a newline seperated lists of areas per elf-duo.


  ## Parameters

    - string_input: newline-split records of elves.

  ## Examples

      iex> CleanUpCampDebugger.get_fully_covered_double_jobs_for_pairs(input)
      12

  """
  def get_fully_covered_double_jobs_for_pairs(string_input) do
    string_input
    |> split_results_per_elf()
    |> split_per_pair_to_ranges()
    |> check_full_overlap()
    |> count_all_true_answers()
  end

  @doc """
  Checks if one elf has been assigned to part of the work of the other elf in
  the couple.
  expects a newline seperated lists of areas per elf-duo.


  ## Parameters

    - string_input: newline-split records of elves.

  ## Examples

      iex> CleanUpCampDebugger.get_fully_covered_double_jobs_for_pairs(input)
      12

  """
  def get_partially_covered_double_jobs_for_pairs(string_input) do
    string_input
    |> split_results_per_elf()
    |> split_per_pair_to_ranges()
    |> check_partial_overlap()
    |> count_all_true_answers()
  end

  defp split_results_per_elf(stringed_list) do
    stringed_list
    |> String.split("\n")
    |> Enum.reject(fn item -> item == "" end)
  end

  defp split_per_pair_to_ranges(pairs_list) do
    pairs_list
    |> Enum.map(fn item ->
      # captures: (number)-(number),(number)-(number)
      [[_, start_1, end_1, start_2, end_2]] = Regex.scan(~r/^(\d+?)-(\d+?),(\d+?)-(\d+?)$/, item)
      elf_1 = String.to_integer(start_1)..String.to_integer(end_1)
      elf_2 = String.to_integer(start_2)..String.to_integer(end_2)

      %{elf_1: elf_1, elf_2: elf_2}
    end)
  end

  defp check_full_overlap(elf_pairs) do
    elf_pairs
    |> Enum.map(fn %{elf_1: elf_1, elf_2: elf_2} ->
      elf_1_unique_work =
        Enum.reject(elf_1, fn area -> Enum.member?(elf_2, area) end) |> Enum.count()

      elf_2_unique_work =
        Enum.reject(elf_2, fn area -> Enum.member?(elf_1, area) end) |> Enum.count()

      if elf_1_unique_work == 0 || elf_2_unique_work == 0, do: true, else: false
    end)
  end

  defp check_partial_overlap(elf_pairs) do
    elf_pairs
    |> Enum.map(fn %{elf_1: elf_1, elf_2: elf_2} ->
      elf_1_total_work = Enum.count(elf_1)
      elf_2_total_work = Enum.count(elf_2)

      elf_1_unique_work =
        elf_1
        |> Enum.reject(fn area -> Enum.member?(elf_2, area) end)
        |> Enum.count()

      elf_2_unique_work =
        elf_2
        |> Enum.reject(fn area -> Enum.member?(elf_1, area) end)
        |> Enum.count()

      elf_1_total_work != elf_1_unique_work || elf_2_total_work != elf_2_unique_work
    end)
  end

  defp count_all_true_answers(answers) do
    answers
    |> Enum.reject(fn answer -> !answer end)
    |> Enum.count()
  end
end

defmodule Day4Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/4
  """

  def read_test do
    """
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    """
  end

  def read_fixture do
    File.read!("test/04/fixture/cleaning_assignments.txt")
  end

  test "Puzzle 1: Get number of cleaning pairs where one elf does another elf's entire job" do
    test_contents = read_test()

    test_result = CleanUpCampDebugger.get_fully_covered_double_jobs_for_pairs(test_contents)
    assert test_result == 2

    real_contents = read_fixture()
    real_result = CleanUpCampDebugger.get_fully_covered_double_jobs_for_pairs(real_contents)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: Get number of cleaning pairs where one elf does part of the other elf's job" do
    test_contents = read_test()

    test_result = CleanUpCampDebugger.get_partially_covered_double_jobs_for_pairs(test_contents)
    assert test_result == 4

    real_contents = read_fixture()
    real_result = CleanUpCampDebugger.get_partially_covered_double_jobs_for_pairs(real_contents)
    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

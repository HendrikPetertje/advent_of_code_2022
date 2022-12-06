defmodule SubroutineMachine do
  @moduledoc """
  This module finds the first set of x unique characters in a list and returns
  the position of the those unique charactes + 1.
  """

  @doc """
  Get the start marker position

  ## Parameters

    - input_data: the message.
    - unique_required: number of unique numers required.

  ## Examples

      iex> get_message_start_marker_position(test_data, 4)
      12

  """
  def get_start_marker_position(test_data, unique_required) do
    test_data
    |> remove_newline()
    |> string_to_codepoints()
    |> get_marker_position(0, unique_required)
  end

  defp remove_newline(test_data) do
    String.replace(test_data, "\n", "")
  end

  defp string_to_codepoints(test_data) do
    String.codepoints(test_data)
  end

  defp get_marker_position([], _, _), do: throw("no start marker found")

  defp get_marker_position(list, iteration, unique_required) do
    first_x = list |> Enum.take(unique_required)

    case first_x |> Enum.uniq() |> Enum.count() == unique_required do
      true -> iteration + unique_required
      false -> list |> Enum.drop(1) |> get_marker_position(iteration + 1, unique_required)
    end
  end
end

defmodule Day6Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/6
  """

  def read_test do
    """
    zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw
    """
  end

  def read_fixture do
    File.read!("test/06/fixture/elf_message.txt")
  end

  test "Puzzle 1: Get start of packet marker (the next character after 4 unique characters)" do
    test_data = read_test()

    test_result = SubroutineMachine.get_start_marker_position(test_data, 4)
    assert test_result == 11

    real_data = read_fixture()
    real_result = SubroutineMachine.get_start_marker_position(real_data, 4)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: Get start of message marker (the next character after 14 unique characters)" do
    test_data = read_test()

    test_result = SubroutineMachine.get_start_marker_position(test_data, 14)
    assert test_result == 26

    real_data = read_fixture()
    real_result = SubroutineMachine.get_start_marker_position(real_data, 14)
    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

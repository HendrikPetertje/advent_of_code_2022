defmodule DistressMachine do
  @moduledoc """
  module-wide docs
  """

  @doc """
  What does this do?

  ## Parameters

    - input_data: newline-split records of something.

  ## Examples

      iex> example(input_data)
      TBD

  """
  def indices_of_data_in_right_order(input_data) do
    input_data
    |> input_data_to_blocks()
    |> parse_json_of_block_data()
    |> compare_data()
    |> indices_of_lefts_that_where_less
  end

  def decoder_key_for_sorted_packets(input_data) do
    input_data
    |> input_data_to_steam()
    |> parse_json_of_stream()
    |> sort_by_compare()
    |> find_indices_of_divider_packets()
  end

  # 1 everything to blocks or streams
  defp input_data_to_blocks(input_data) do
    input_data
    |> String.split("\n\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn block ->
      block
      |> String.split("\n")
      |> Enum.reject(&(&1 == ""))
    end)
  end

  defp input_data_to_steam(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
  end

  # 2 get json-ish data
  defp parse_json_of_block_data(block_data) do
    block_data
    |> Enum.map(fn [left, right] ->
      [
        Jason.decode!(left),
        Jason.decode!(right)
      ]
    end)
  end

  defp parse_json_of_stream(stream_data) do
    stream_data
    |> Enum.map(fn line -> Jason.decode!(line) end)
  end

  # 3 (Assignment 2) sort by same compare as assignment 1
  defp sort_by_compare(decoded_data) do
    [[[2]], [[6]] | decoded_data]
    |> Enum.sort(&compare/2)
  end

  # 3 Compare everything
  defp compare_data(decoded_data) do
    decoded_data
    |> Enum.map(fn [left, right] -> compare(left, right) end)
  end

  # All compares
  defp compare([same_head | l_tail], [same_head | r_tail]), do: compare(l_tail, r_tail)
  defp compare([], []), do: :equal
  defp compare([], [_ | _]), do: true
  defp compare([_ | _], []), do: false

  defp compare([l_head | l_tail], [r_head | r_tail]) do
    case compare_value(l_head, r_head) do
      :equal -> compare(l_tail, r_tail)
      answer -> answer
    end
  end

  defp compare_value(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> true
      left == right -> :equal
      left > right -> false
    end
  end

  # List wrap, wraps items in arrays if they haven't been already
  defp compare_value(left, right), do: compare(List.wrap(left), List.wrap(right))

  # Indices
  defp indices_of_lefts_that_where_less(list) do
    list
    |> Enum.with_index(1)
    # This is neat object grabbing, I need to remember this
    |> Enum.filter(&(elem(&1, 0) == true))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp find_indices_of_divider_packets(sorted_data) do
    divider_1 = Enum.find_index(sorted_data, &(&1 == [[2]])) + 1
    divider_2 = Enum.find_index(sorted_data, &(&1 == [[6]])) + 1

    divider_1 * divider_2
  end
end

defmodule Day13Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/13
  """

  def read_test do
    """
    [1,1,3,1,1]
    [1,1,5,1,1]

    [[1],[2,3,4]]
    [[1],4]

    [9]
    [[8,7,6]]

    [[4,4],4,4]
    [[4,4],4,4,4]

    [7,7,7,7]
    [7,7,7]

    []
    [3]

    [[[]]]
    [[]]

    [1,[2,[3,[4,[5,6,7]]]],8,9]
    [1,[2,[3,[4,[5,6,0]]]],8,9]
    """
  end

  def read_fixture do
    File.read!("test/13/fixture/the_message.txt")
  end

  test "Puzzle 1: Indices of right packets" do
    test_data = read_test()

    test_result = DistressMachine.indices_of_data_in_right_order(test_data)
    assert test_result == 13

    real_data = read_fixture()
    real_result = DistressMachine.indices_of_data_in_right_order(real_data)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: " do
    test_data = read_test()

    test_result = DistressMachine.decoder_key_for_sorted_packets(test_data)
    assert test_result == 140

    real_data = read_fixture()
    real_result = DistressMachine.decoder_key_for_sorted_packets(real_data)
    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

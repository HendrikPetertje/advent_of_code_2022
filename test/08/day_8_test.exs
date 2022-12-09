defmodule TreeHouseLocatorMachine do
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
  def count_visible_trees(input_data, debug_map) do
    input_data
    |> divide_per_line()
    |> map_to_list_of_heights()
    # Look from the left
    |> find_visible_items()
    # Look from the right
    |> reverse_lines()
    |> find_visible_items()
    # Look from the top
    |> rotate_lines()
    |> find_visible_items()
    # Look from the bottom
    |> reverse_lines()
    |> find_visible_items()
    # back to begin for debug sake
    |> reverse_lines()
    |> rotate_lines()
    |> reverse_lines()
    # simplify somewhat
    |> simplify_to_visible()
    # Puts a map
    |> fancy_puts(debug_map)
    # Count visible
    |> count_visible()

    # Design:
    # Divide per line and remove trailing newline
    # Map everything to [number, boolean] where boolean is visible or not
    # Reverse the grid and look again creating [number, boolean, boolean]
    # turn the grid 90° and look again creating [number, boolean, boolean, boolean]
    # reverse the grid and look again creating [number, boolean, boolean, boolean, boolean]
  end

  def get_scenic_score_of_best_scenic_tree(input_data, debug_map) do
    input_data
    |> divide_per_line()
    |> map_to_list_of_heights()

    # Look from the left and get scenic score
    |> map_scenic_scores()
    # Look from the right and get scenic score
    |> reverse_lines()
    |> map_scenic_scores()
    # Look from the top
    |> rotate_lines()
    |> map_scenic_scores()
    # Look from the bottom
    |> reverse_lines()
    |> map_scenic_scores()
    # back to begin for debug sake
    |> reverse_lines()
    |> rotate_lines()
    |> reverse_lines()
    # Simplify_to_scenic
    |> calculate_total_scenic_scores()
    |> get_highest_scenic_score()
    |> inspect_highest_scenic_score_on_map(debug_map)
  end

  # 1 divide and clean up
  defp divide_per_line(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.reject(fn item -> item == "" end)
  end

  # 2 prepare for testing
  defp map_to_list_of_heights(lines) do
    lines
    |> Enum.map(fn line ->
      line
      |> String.codepoints()
      |> Enum.map(fn point -> [point |> String.to_integer()] end)
    end)
  end

  # Perform rotations and reverses
  defp reverse_lines(line_data) do
    line_data
    |> Enum.map(fn line -> line |> Enum.reverse() end)
  end

  defp rotate_lines(line_data) do
    width = (List.first(line_data) |> Enum.count()) - 1
    height = (line_data |> Enum.count()) - 1

    0..width
    |> Enum.map(fn x ->
      0..height
      |> Enum.map(fn y ->
        line_data |> Enum.at(y) |> Enum.at(x)
      end)
    end)
  end

  # run the actual checks
  defp find_visible_items(line_data) do
    line_data
    |> Enum.map(fn line -> iterate_visible_check(line) end)
  end

  # have to go -1 here, to be lower than the 0 at some of the edges
  defp iterate_visible_check(inputs, highest \\ -1, results \\ [])
  defp iterate_visible_check([], _, results), do: results

  defp iterate_visible_check([[item | _] = input | rest], highest, results) do
    result = List.insert_at(input, -1, item > highest)

    new_highest = max(highest, item)
    new_results = List.insert_at(results, -1, result)

    iterate_visible_check(rest, new_highest, new_results)
  end

  # Simplify and puts the data
  defp simplify_to_visible(line_data) do
    Enum.map(line_data, fn line ->
      Enum.map(line, fn [item | visible_map] ->
        [
          item,
          Enum.member?(visible_map, true)
        ]
      end)
    end)
  end

  defp fancy_puts(line_data, debug_map) do
    data =
      Enum.map(line_data, fn line ->
        line
        |> Enum.map(fn [name, visible] ->
          case visible do
            true ->
              IO.ANSI.green() <> "#{name}" <> IO.ANSI.reset()

            false ->
              IO.ANSI.red() <> "#{name}" <> IO.ANSI.reset()
          end
        end)
        |> Enum.join()
      end)
      |> Enum.join("\n")

    if debug_map, do: IO.puts("\n" <> data)

    line_data
  end

  # Count for assignment 1
  defp count_visible(line_data) do
    line_data
    |> Enum.map(fn line ->
      line
      |> Enum.reject(fn [_, visible] -> !visible end)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  # 
  defp map_scenic_scores(line_data) do
    line_data
    |> Enum.map(fn line -> iterate_scneic_scores(line) end)
  end

  # Iterate over each, finding out how far one can see
  defp iterate_scneic_scores(items, results \\ [])
  defp iterate_scneic_scores([], results), do: results

  defp iterate_scneic_scores([[item | _] = input | rest], results) do
    result = List.insert_at(input, -1, forward_until_higher(item, rest, 0))
    new_results = List.insert_at(results, -1, result)

    iterate_scneic_scores(rest, new_results)
  end

  defp forward_until_higher(_, [], iteration), do: iteration

  defp forward_until_higher(item, [[next_height | _] | rest], iteration) do
    case item > next_height do
      true -> forward_until_higher(item, rest, iteration + 1)
      false -> iteration + 1
    end
  end

  defp calculate_total_scenic_scores(line_data) do
    Enum.map(line_data, fn line ->
      line
      |> Enum.map(fn [item | scores] -> [item, Enum.reduce(scores, &multiply/2)] end)
    end)
  end

  defp multiply(x, y) do
    x * y
  end

  defp get_highest_scenic_score(line_data) do
    result =
      line_data
      |> Enum.map(fn line ->
        line
        |> Enum.map(fn [itemm, score] -> score end)
        |> Enum.sort()
        |> List.last()
      end)
      |> Enum.sort()
      |> List.last()

    [result, line_data]
  end

  defp inspect_highest_scenic_score_on_map([highest_scenic, line_data], debug_map) do
    data =
      Enum.map(line_data, fn line ->
        line
        |> Enum.map(fn [name, score] ->
          case score == highest_scenic do
            true ->
              IO.ANSI.green() <> "#{name}" <> IO.ANSI.reset()

            false ->
              IO.ANSI.red() <> "#{name}" <> IO.ANSI.reset()
          end
        end)
        |> Enum.join()
      end)
      |> Enum.join("\n")

    if debug_map, do: IO.puts("\n" <> data)

    highest_scenic
  end
end

defmodule Day8Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/8
  """

  def read_test do
    """
    30373
    25512
    65332
    33549
    35390
    """
  end

  def read_fixture do
    File.read!("test/08/fixture/treehouse_grid.txt")
  end

  test "Puzzle 1: Get total number of visible trees" do
    test_data = read_test()

    test_result = TreeHouseLocatorMachine.count_visible_trees(test_data, false)
    assert test_result == 21

    real_data = read_fixture()
    real_result = TreeHouseLocatorMachine.count_visible_trees(real_data, false)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: Get scenic score of the higest tree" do
    test_data = read_test()

    test_result = TreeHouseLocatorMachine.get_scenic_score_of_best_scenic_tree(test_data, false)
    assert test_result == 8

    real_data = read_fixture()
    real_result = TreeHouseLocatorMachine.get_scenic_score_of_best_scenic_tree(real_data, false)
    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

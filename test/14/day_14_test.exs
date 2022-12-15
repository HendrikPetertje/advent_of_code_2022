defmodule MapHelper do
  def create_map(rock_data, sand_data, there_is_a_floor) do
    list_of_x = rock_data |> Enum.map(&elem(&1, 0)) |> Enum.sort()
    list_of_y = rock_data |> Enum.map(&elem(&1, 1)) |> Enum.sort()

    lowest_x = list_of_x |> List.first()
    highest_x = list_of_x |> List.last()

    lowest_y = 0
    highest_y = list_of_y |> List.last()

    map_data =
      Enum.map(lowest_y..(highest_y + 3), fn y ->
        Enum.map((lowest_x - 10)..(highest_x + 10), fn x ->
          cond do
            Enum.member?(rock_data, {x, y}) -> "#"
            Enum.member?(sand_data, {x, y}) -> "+"
            y == highest_y + 2 && there_is_a_floor -> "‰"
            true -> "."
          end
        end)
        |> Enum.join()
      end)
      |> Enum.join("\n")

    IO.puts("\n#{map_data}")
  end
end

defmodule RegolithMachine do
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
  def number_of_sand_blocks_that_rest(input_data, there_is_a_floor) do
    rock_data =
      input_data
      |> seperate_data_to_machine_data()
      |> Enum.map(&create_list_of_rock_locations/1)
      |> List.flatten()

    # Optimize, grab this data once
    lowest_rock_y = rock_data |> Enum.map(&elem(&1, 1)) |> Enum.sort() |> List.last()

    sand_data = drop_sand(rock_data, there_is_a_floor, lowest_rock_y)

    # Fancy map
    MapHelper.create_map(rock_data, sand_data, there_is_a_floor)

    sand_data |> Enum.count()
  end

  defp seperate_data_to_machine_data(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ")
      |> Enum.map(fn coordinate ->
        %{"x" => x, "y" => y} = Regex.named_captures(~r/^(?<x>.+?),(?<y>.+?)$/, coordinate)
        {String.to_integer(x), String.to_integer(y)}
      end)
    end)
  end

  defp create_list_of_rock_locations(pois, rock_locations \\ [])

  defp create_list_of_rock_locations([last_poi], rock_locations) do
    (rock_locations ++ [last_poi]) |> Enum.uniq()
  end

  defp create_list_of_rock_locations([poi_1, poi_2 | rest], rock_locations) do
    new_locations = spawn_locations(poi_1, poi_2)

    create_list_of_rock_locations([poi_2] ++ rest, rock_locations ++ new_locations)
  end

  defp spawn_locations({same_x, yh}, {same_x, yt}) do
    yh..yt |> Enum.map(fn y -> {same_x, y} end)
  end

  defp spawn_locations({xh, same_y}, {xt, same_y}) do
    xh..xt |> Enum.map(fn x -> {x, same_y} end)
  end

  defp drop_sand(
         rock_data,
         there_is_a_floor,
         lowest_rock_y,
         sand_data \\ [],
         sand_position \\ {500, 0}
       )

  defp drop_sand(rock_data, there_is_a_floor, lowest_rock_y, sand_data, {x, y}) do
    locs = %{
      down: {x, y + 1},
      down_left: {x - 1, y + 1},
      down_right: {x + 1, y + 1}
    }

    no_rock_or_sand_at_loc = fn location ->
      !Enum.member?(rock_data, location) && !Enum.member?(sand_data, location)
    end

    not_falling_on_infinite_floor = fn {_x, y} ->
      cond do
        !there_is_a_floor -> true
        y > lowest_rock_y + 1 -> false
        true -> true
      end
    end

    beyond_lowest_rock = fn ->
      y > lowest_rock_y && !there_is_a_floor
    end

    sand_blocking_roof = fn ->
      y == 0
    end

    cond do
      beyond_lowest_rock.() ->
        sand_data

      no_rock_or_sand_at_loc.(locs.down) && not_falling_on_infinite_floor.(locs.down) ->
        drop_sand(rock_data, there_is_a_floor, lowest_rock_y, sand_data, locs.down)

      no_rock_or_sand_at_loc.(locs.down_left) && not_falling_on_infinite_floor.(locs.down_left) ->
        drop_sand(rock_data, there_is_a_floor, lowest_rock_y, sand_data, locs.down_left)

      no_rock_or_sand_at_loc.(locs.down_right) && not_falling_on_infinite_floor.(locs.down_right) ->
        drop_sand(rock_data, there_is_a_floor, lowest_rock_y, sand_data, locs.down_right)

      sand_blocking_roof.() ->
        [{x, y} | sand_data]

      true ->
        drop_sand(rock_data, there_is_a_floor, lowest_rock_y, [{x, y} | sand_data])
    end
  end
end

defmodule Day14Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/14
  """

  def read_test do
    """
    498,4 -> 498,6 -> 496,6
    503,4 -> 502,4 -> 502,9 -> 494,9
    """
  end

  def read_fixture do
    File.read!("test/14/fixture/tunnel_scan.txt")
  end

  test "Puzzle 1: TB" do
    test_data = read_test()

    test_result = RegolithMachine.number_of_sand_blocks_that_rest(test_data, false)
    assert test_result == 24

    real_data = read_fixture()
    real_result = RegolithMachine.number_of_sand_blocks_that_rest(real_data, false)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: TB" do
    test_data = read_test()

    test_result = RegolithMachine.number_of_sand_blocks_that_rest(test_data, true)
    assert test_result == 93

    # Disabling this, because it runs too long for CI
    # real_data = read_fixture()
    # real_result = RegolithMachine.number_of_sand_blocks_that_rest(real_data, true)
    # IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

defmodule MiniDb do
  use GenServer

  @me __MODULE__

  def start_link(_info) do
    start()
  end

  def start(default \\ %{}) do
    GenServer.start(__MODULE__, default, name: @me)
  end

  def set(key, value) do
    GenServer.cast(@me, {:set, key, value})
  end

  def get(key) do
    GenServer.call(@me, {:get, key})
  end

  def keys do
    GenServer.call(@me, {:keys})
  end

  def wipe do
    GenServer.cast(@me, {:wipe})
  end

  def init(args) do
    {:ok, Enum.into(args, %{})}
  end

  def handle_cast({:set, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_cast({:wipe}, _state) do
    {:noreply, %{}}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, state[key], state}
  end

  def handle_call({:keys}, _from, state) do
    {:reply, Map.keys(state), state}
  end
end

defmodule ClimbingMachine do
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
  def find_path_to_top(input_data, reverse_to_a) do
    input_data
    |> parse_rows_to_coordinates()
    |> find_start(reverse_to_a)
    |> find_end(reverse_to_a)

    fetch_best_success()
  end

  # 1 make data machin readable
  defp parse_rows_to_coordinates(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.reject(fn line -> line == "" end)
    |> Enum.with_index(fn line, line_index ->
      line
      |> String.codepoints()
      |> Enum.with_index(fn point, index -> {line_index, index, point} end)
    end)
    |> List.flatten()
  end

  # Find the start point
  defp find_start(coordinates, reverse_to_a) do
    point_to_find = if reverse_to_a, do: "E", else: "S"
    start = coordinates |> Enum.find(fn {_, _, point} -> point == point_to_find end)
    [start, coordinates]
  end

  # Go to the end and save all successful paths to our little genserver
  defp find_end(data, reverse_to_a, visited \\ [])

  defp find_end([{_prev_x, _prev_y, "E"}, _coordinates], false, visited) do
    key = "goal_#{Enum.join(visited, ">")}"
    value = visited

    MiniDb.set(key, value)
  end

  defp find_end([{_prev_x, _prev_y, "a"}, _coordinates], true, visited) do
    key = "goal_#{Enum.join(visited, ">")}"
    value = visited

    MiniDb.set(key, value)
  end

  defp find_end([{prev_x, prev_y, prev_point}, coordinates], reverse_to_a, visited) do
    prev_key = create_key({prev_x, prev_y, prev_point})
    visited_count = Enum.count(visited)

    case visited_before_quicker(prev_key, visited_count) do
      true ->
        nil

      false ->
        MiniDb.set(prev_key, visited_count)

        above =
          Enum.find(coordinates, fn {x, y, point} ->
            prev_x - 1 == x && prev_y == y && should_visit(point, prev_point, reverse_to_a)
          end)

        right =
          Enum.find(coordinates, fn {x, y, point} ->
            prev_x == x && prev_y + 1 == y && should_visit(point, prev_point, reverse_to_a)
          end)

        down =
          Enum.find(coordinates, fn {x, y, point} ->
            prev_x + 1 == x && prev_y == y && should_visit(point, prev_point, reverse_to_a)
          end)

        left =
          Enum.find(coordinates, fn {x, y, point} ->
            prev_x == x && prev_y - 1 == y && should_visit(point, prev_point, reverse_to_a)
          end)

        run_above = above && !has_visited(above, visited)
        run_right = right && !has_visited(right, visited)
        run_down = down && !has_visited(down, visited)
        run_left = left && !has_visited(left, visited)

        above_exec =
          if run_above,
            do:
              Task.async(fn ->
                find_end([above, coordinates], reverse_to_a, visited ++ [create_key(above)])
              end),
            else: Task.async(fn -> nil end)

        right_exec =
          if run_right,
            do:
              Task.async(fn ->
                find_end([right, coordinates], reverse_to_a, visited ++ [create_key(right)])
              end),
            else: Task.async(fn -> nil end)

        down_exec =
          if run_down,
            do:
              Task.async(fn ->
                find_end([down, coordinates], reverse_to_a, visited ++ [create_key(down)])
              end),
            else: Task.async(fn -> nil end)

        left_exec =
          if run_left,
            do:
              Task.async(fn ->
                find_end([left, coordinates], reverse_to_a, visited ++ [create_key(left)])
              end),
            else: Task.async(fn -> nil end)

        Task.yield_many([above_exec, right_exec, down_exec, left_exec], 20_000)
    end
  end

  defp should_visit(point, origin, reverse_to_a) do
    point_num = letter_as_num(point)
    origin_num = letter_as_num(origin)

    case reverse_to_a do
      true -> origin_num - 1 <= point_num
      false -> origin_num + 1 >= point_num
    end
  end

  # Fetch all successful paths from genserver
  defp fetch_best_success do
    MiniDb.keys()
    |> Enum.reject(fn key -> !Regex.match?(~r/goal_/, key) end)
    |> Enum.map(fn key ->
      key
      |> MiniDb.get()
      |> Enum.count()
    end)
    |> Enum.sort()
    |> List.first()
  end

  # Helpers
  defp letter_as_num(letter) do
    case letter do
      "S" -> 1
      "a" -> 2
      "b" -> 3
      "c" -> 4
      "d" -> 5
      "e" -> 6
      "f" -> 7
      "g" -> 8
      "h" -> 9
      "i" -> 10
      "j" -> 11
      "k" -> 12
      "l" -> 13
      "m" -> 14
      "n" -> 15
      "o" -> 16
      "p" -> 17
      "q" -> 18
      "r" -> 19
      "s" -> 20
      "t" -> 21
      "u" -> 22
      "v" -> 23
      "w" -> 24
      "x" -> 25
      "y" -> 26
      "z" -> 27
      "E" -> 28
    end
  end

  defp create_key({x, y, _}) do
    "#{x}.#{y}"
  end

  defp visited_before_quicker(key, visited_no) do
    before = MiniDb.get(key)

    cond do
      # visited_no > 4000 -> true
      before == nil -> false
      before > visited_no -> false
      true -> true
    end
  end

  defp has_visited(nil, _), do: false

  defp has_visited(coordinate, visited) do
    key = create_key(coordinate)
    if Enum.find(visited, fn item -> item == key end), do: true, else: false
  end
end

defmodule Day12Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/12
  """

  def read_test do
    """
    Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi
    """
  end

  def read_fixture do
    File.read!("test/12/fixture/the_hills.txt")
  end

  test "Puzzle 1: find quickest path to End" do
    MiniDb.start()

    test_data = read_test()

    test_result = ClimbingMachine.find_path_to_top(test_data, false)
    assert test_result == 31

    MiniDb.wipe()

    real_data = read_fixture()
    real_result = ClimbingMachine.find_path_to_top(real_data, false)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")

    MiniDb.wipe()
  end

  test "Puzzle 2: find quickest path to any a" do
    MiniDb.start()

    test_data = read_test()

    test_result = ClimbingMachine.find_path_to_top(test_data, true)
    assert test_result == 29

    MiniDb.wipe()

    real_data = read_fixture()
    real_result = ClimbingMachine.find_path_to_top(real_data, true)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")

    MiniDb.wipe()
  end
end

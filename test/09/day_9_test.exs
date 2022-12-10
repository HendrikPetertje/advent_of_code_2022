defmodule RopeBridgeMachine do
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
  def find_tail_steps(input_data) do
    input_data
    |> divide_by_newlines()
    |> divide_by_instruction()
    |> perform_instruction()
    |> find_unique_positions()
  end

  def find_rope_steps(input_data) do
    input_data
    |> divide_by_newlines()
    |> divide_by_instruction()
    |> perform_rope_instruction()
    |> find_unique_positions()
  end

  defp divide_by_newlines(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.reject(fn line -> line == "" end)
  end

  defp divide_by_instruction(input_lines) do
    input_lines
    |> Enum.map(fn line ->
      [direction, amount] = String.split(line, " ")

      [
        direction,
        String.to_integer(amount)
      ]
    end)
  end

  # assignment 1
  defp perform_instruction(
         instructions,
         pos_head \\ [0, 4],
         pos_tail \\ [0, 4],
         tail_positions \\ []
       )

  defp perform_instruction([], _, _, tail_positions), do: tail_positions

  defp perform_instruction(
         [[_, 0] | rest],
         pos_head,
         pos_tail,
         tail_positions
       ) do
    perform_instruction(rest, pos_head, pos_tail, tail_positions)
  end

  defp perform_instruction(
         [[direction, amount] | rest],
         pos_head,
         pos_tail,
         tail_positions
       ) do
    new_amount = amount - 1
    new_pos_head = get_new_pos_head(direction, pos_head)
    [new_pos_tail, hash] = get_new_pos_rope(new_pos_head, pos_tail)

    perform_instruction(
      [[direction, new_amount] | rest],
      new_pos_head,
      new_pos_tail,
      List.insert_at(tail_positions, -1, hash)
    )
  end

  # Assignment 5
  defp perform_rope_instruction(
         instructions,
         pos_head \\ [12, 20],
         pos_1 \\ [12, 20],
         pos_2 \\ [12, 20],
         pos_3 \\ [12, 20],
         pos_4 \\ [12, 20],
         pos_5 \\ [12, 20],
         pos_6 \\ [12, 20],
         pos_7 \\ [12, 20],
         pos_8 \\ [12, 20],
         pos_9 \\ [12, 20],
         tail_positions \\ []
       )

  defp perform_rope_instruction(
         [],
         _,
         _,
         _,
         _,
         _,
         _,
         _,
         _,
         _,
         _,
         tail_positions
       ),
       do: tail_positions

  defp perform_rope_instruction(
         [[_, 0] | rest],
         pos_head,
         pos_1,
         pos_2,
         pos_3,
         pos_4,
         pos_5,
         pos_6,
         pos_7,
         pos_8,
         pos_9,
         tail_positions
       ) do
    perform_rope_instruction(
      rest,
      pos_head,
      pos_1,
      pos_2,
      pos_3,
      pos_4,
      pos_5,
      pos_6,
      pos_7,
      pos_8,
      pos_9,
      tail_positions
    )
  end

  defp perform_rope_instruction(
         [[direction, amount] = instruction | rest],
         pos_head,
         pos_1,
         pos_2,
         pos_3,
         pos_4,
         pos_5,
         pos_6,
         pos_7,
         pos_8,
         pos_9,
         tail_positions
       ) do
    new_amount = amount - 1

    new_pos_head = get_new_pos_head(direction, pos_head)
    [new_pos_1, _] = get_new_pos_rope(new_pos_head, pos_1)
    [new_pos_2, _] = get_new_pos_rope(new_pos_1, pos_2)
    [new_pos_3, _] = get_new_pos_rope(new_pos_2, pos_3)
    [new_pos_4, _] = get_new_pos_rope(new_pos_3, pos_4)
    [new_pos_5, _] = get_new_pos_rope(new_pos_4, pos_5)
    [new_pos_6, _] = get_new_pos_rope(new_pos_5, pos_6)
    [new_pos_7, _] = get_new_pos_rope(new_pos_6, pos_7)
    [new_pos_8, _] = get_new_pos_rope(new_pos_7, pos_8)
    [new_pos_9, hash] = get_new_pos_rope(new_pos_8, pos_9)

    # Handy debugger!
    # MapInspector.map_out(
    #   [
    #     ["H", new_pos_head],
    #     ["1", new_pos_1],
    #     ["2", new_pos_2],
    #     ["3", new_pos_3],
    #     ["4", new_pos_4],
    #     ["5", new_pos_5],
    #     ["6", new_pos_6],
    #     ["7", new_pos_7],
    #     ["8", new_pos_8],
    #     ["9", new_pos_9]
    #   ],
    #   26,
    #   26
    # )

    perform_rope_instruction(
      [[direction, new_amount] | rest],
      new_pos_head,
      new_pos_1,
      new_pos_2,
      new_pos_3,
      new_pos_4,
      new_pos_5,
      new_pos_6,
      new_pos_7,
      new_pos_8,
      new_pos_9,
      List.insert_at(tail_positions, -1, hash)
    )
  end

  defp get_new_pos_head("R", [x, y]), do: [x + 1, y]
  defp get_new_pos_head("L", [x, y]), do: [x - 1, y]
  defp get_new_pos_head("U", [x, y]), do: [x, y - 1]
  defp get_new_pos_head("D", [x, y]), do: [x, y + 1]

  defp move_knot(h, t) do
    if h - t > 0, do: t + 1, else: t - 1
  end

  defp get_new_pos_rope([hx, hy], [tx, ty]) do
    [new_x, new_y] =
      cond do
        # Next to each other
        abs(hx - tx) <= 1 && abs(hy - ty) <= 1 -> [tx, ty]
        # Same line
        hx == tx -> [tx, move_knot(hy, ty)]
        # Same column
        hy == ty -> [move_knot(hx, tx), ty]
        # default
        true -> [move_knot(hx, tx), move_knot(hy, ty)]
      end

    [[new_x, new_y], "#{new_x}.#{new_y}"]
  end

  defp find_unique_positions(tail_positions) do
    tail_positions
    |> Enum.uniq()
    |> Enum.count()
  end
end

defmodule Day9Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/9
  """

  def read_test do
    """
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
    """
  end

  def read_test_2 do
    """
    R 5
    U 8
    L 8
    D 3
    R 17
    D 10
    L 25
    U 20
    """
  end

  def read_fixture do
    File.read!("test/09/fixture/step_list.txt")
  end

  test "Puzzle 1: Track position of tail" do
    test_data = read_test()

    test_result = RopeBridgeMachine.find_tail_steps(test_data)
    assert test_result == 13

    real_data = read_fixture()
    real_result = RopeBridgeMachine.find_tail_steps(real_data)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: Track position of an entire rope of head and 9 steps" do
    test_data = read_test_2()

    test_result = RopeBridgeMachine.find_rope_steps(test_data)
    assert test_result == 36

    real_data = read_fixture()
    real_result = RopeBridgeMachine.find_rope_steps(real_data)
    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

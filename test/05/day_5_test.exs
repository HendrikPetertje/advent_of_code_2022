defmodule CrateDiagnosticMachine do
  @moduledoc """
  The elves are moving crates to the shore and need to re-configure a thing or two
  so this diagnosic machine calculates that! 
  """

  @doc """
  Takes stack data as exampled in the test below, where there are stacks of crates
  the mover9000 can move a single crate at a time while the mover9001 can move multiple

  ## Parameters

    - input_data: newline-split records of data and actions.
    - number_of_stacks: newline-split number of stacks the elves want to create.
    - can_move_multiple_at_once: if the crane can move multiple boxes at once.

  ## Examples

      iex> calculate_new_top_after_reconfig(input_data, 9, true)
      12

  """
  def calculate_new_top_after_reconfig(input_data, can_move_multiple_at_once) do
    input_data
    |> get_number_of_stacks()
    |> parse_stacks()
    |> parse_actions()
    |> execute_instructions(can_move_multiple_at_once)
    |> render_output()
  end

  # 1
  defp get_number_of_stacks(input_data) do
    number_of_stacks =
      input_data
      # divide between stacks and actions
      |> String.split("\n\n")
      |> List.first()
      # divide between lines
      |> String.split("\n")
      |> List.last()
      |> String.split("\s\s\s")
      |> Enum.count()

    %{input_data: input_data, number_of_stacks: number_of_stacks}
  end

  # 2
  defp parse_stacks(input) do
    %{input_data: input_data, number_of_stacks: number_of_stacks} = input
    # Split initial data apart from stack
    [stack_data | _] = input_data |> String.split("\n 1")
    split_stack_data = stack_data |> String.split("\n")

    # Named regex strigng
    regex_string =
      ~r"^#{Enum.map(1..number_of_stacks, fn num -> ~S"(\[(?<res" <> "#{num}" <> ~S">\w)\]|(\s{3}))" end) |> Enum.join(~S"\s")}$"

    capts =
      Enum.map(split_stack_data, fn line ->
        Regex.named_captures(regex_string, line)
      end)

    stacks =
      1..number_of_stacks
      |> Enum.map(fn item -> %{"stack#{item}" => captures_to_list(capts, "res#{item}")} end)
      |> Enum.reduce(&Map.merge/2)

    %{stacks: stacks, input_data: input_data}
  end

  defp captures_to_list(capts, key) do
    capts
    |> Enum.map(fn capt -> capt[key] end)
    |> Enum.reject(fn item -> item == "" || item == nil end)
    |> Enum.reverse()
  end

  # 3
  defp parse_actions(input) do
    %{stacks: stacks, input_data: input_data} = input

    # Split actions from stack
    [_ | [raw_actions]] = input_data |> String.split("\n\n")

    actions =
      raw_actions
      |> String.split("\n")
      |> Enum.reject(fn line -> line == "" end)
      |> Enum.map(fn line ->
        Regex.named_captures(~r/^move (?<num>\d+?) from (?<from>\d) to (?<to>\d)$/, line)
      end)

    %{stacks: stacks, actions: actions}
  end

  # 4
  defp execute_instructions(input, can_move_multiple_at_once) do
    %{stacks: stacks, actions: actions} = input

    execute(stacks, Enum.reverse(actions), can_move_multiple_at_once)
  end

  def execute(stacks, [], _), do: stacks

  def execute(stacks, [instruction | tail], can_move_multiple_at_once) do
    previous_stacks = execute(stacks, tail, can_move_multiple_at_once)

    %{"num" => num, "from" => from, "to" => to} = instruction
    [stacks_step_1, numbers] = calculate_removal(previous_stacks, "stack#{from}", num)
    calculate_adding(stacks_step_1, "stack#{to}", numbers, can_move_multiple_at_once)
  end

  defp calculate_removal(stacks, from, num) do
    to_remove = 0 - String.to_integer(num)
    taken = Enum.take(stacks[from], to_remove)
    new_list = Enum.drop(stacks[from], to_remove)

    [
      Map.merge(stacks, %{"#{from}" => new_list}),
      taken
    ]
  end

  defp calculate_adding(stacks, to, numbers, can_move_multiple_at_once) do
    # Need to reverse since they are taken one by one
    to_add = if can_move_multiple_at_once, do: numbers, else: Enum.reverse(numbers)
    new_list = Enum.concat(stacks[to], to_add)

    Map.merge(stacks, %{"#{to}" => new_list})
  end

  # 5
  defp render_output(stacks) do
    stacks
    |> Map.keys()
    |> Enum.map(fn key -> stacks[key] |> List.last() end)
    |> Enum.join()
  end
end

defmodule Day5Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/5
  """

  # It's important to keep the extra white spaces after!
  def read_test do
    """
        [D]    
    [N] [C]    
    [Z] [M] [P]
     1   2   3 

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
    """
  end

  def read_fixture do
    File.read!("test/05/fixture/moving_list.txt")
  end

  test "Puzzle 1: Follow instructions and see what ends up on top with Mover 9000" do
    test_data = read_test()

    test_result = CrateDiagnosticMachine.calculate_new_top_after_reconfig(test_data, false)
    assert test_result == "CMZ"

    real_data = read_fixture()
    real_result = CrateDiagnosticMachine.calculate_new_top_after_reconfig(real_data, false)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: Follow instructions and see what ends up on top with Mover 9001" do
    test_data = read_test()

    test_result = CrateDiagnosticMachine.calculate_new_top_after_reconfig(test_data, true)
    assert test_result == "MCD"

    real_data = read_fixture()
    real_result = CrateDiagnosticMachine.calculate_new_top_after_reconfig(real_data, true)
    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

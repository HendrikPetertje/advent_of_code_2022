defmodule ExtraMath do
  # https://programming-idioms.org/idiom/75/compute-lcm/983/elixir
  # Compute the least common multiple x of big integers a and b when dealing with big numbers
  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, gcd(a, b))
end

defmodule MonkeyMachine do
  @moduledoc """
  Figure out where monkeys are throwing things
  """

  @doc """
  Figure out where monkeys are throwing things after 20 rounds

  ## Parameters

    - input_data: newline-split records of something.

  ## Examples

      iex> example(input_data)
      TBD

  """
  def find_business_by_2_active_monkeys(input_data) do
    input_data
    |> divide_per_instruction()
    |> instruction_to_map()
    |> cycle_through_rounds(0, 20, nil)
    |> get_2_higest_inspect_counts()
  end

  @doc """
  Figure out where monkeys are throwing things after 10,000 rounds
  The extra kicker is that we have a number that grows to several megabytes.
  so there is some special logic involved to deal with keeping the number down
  (lcm)

  ## Parameters

    - input_data: newline-split records of something.

  ## Examples

      iex> example(input_data)
      TBD

  """
  def find_business_by_2_active_monkeys_extra_worried(input_data) do
    map =
      input_data
      |> divide_per_instruction()
      |> instruction_to_map()

    # The number here wll grow too fast, so i need to figure out how to
    # find a least common multiple to relieve the big number during each throw
    lcm_of_divisors =
      map
      |> Enum.map(fn %{divisible: divisible} -> divisible end)
      |> Enum.reduce(&ExtraMath.lcm/2)

    map
    |> cycle_through_rounds(0, 10_000, lcm_of_divisors)
    |> get_2_higest_inspect_counts()
  end

  defp divide_per_instruction(input_data) do
    input_data
    |> String.split("\n\n")
  end

  defp instruction_to_map(instructions) do
    Enum.map(instructions, fn instruction ->
      [_name_line, items_line, operation_line, test_line, true_line, false_line] =
        instruction
        |> String.split("\n")
        |> Enum.reject(fn line -> line == "" end)

      # The start items
      %{"items" => raw_items} =
        Regex.named_captures(~r/Starting items: (?<items>.+?)$/, items_line)

      items = raw_items |> String.split(", ") |> Enum.map(&String.to_integer/1)

      # divisible number
      %{"divisible" => raw_divisible} =
        Regex.named_captures(~r/Test: divisible by (?<divisible>\d+?)$/, test_line)

      # operation
      %{"x" => x, "operation" => operator, "y" => y} =
        Regex.named_captures(~r/new = (?<x>.+?) (?<operation>.) (?<y>.+?)$/, operation_line)

      operation = %{x: x, operator: operator, y: y}

      divisible = raw_divisible |> String.to_integer()

      # true and false
      %{"monkey" => true_monkey} =
        Regex.named_captures(~r/If true: throw to monkey (?<monkey>\d?)$/, true_line)

      %{"monkey" => false_monkey} =
        Regex.named_captures(~r/If false: throw to monkey (?<monkey>\d+?)$/, false_line)

      %{
        items: items,
        operation: operation,
        divisible: divisible,
        if_true: true_monkey |> String.to_integer(),
        if_false: false_monkey |> String.to_integer(),
        inspected_items: 0
      }
    end)
  end

  defp cycle_through_rounds(monkeys, total_rounds, total_rounds, _lcm_of_divisors), do: monkeys

  defp cycle_through_rounds(monkeys, round, total_rounds, lcm_of_divisors) do
    total_count = Enum.count(monkeys)
    new_monkeys = inspect_and_throw_items(0, monkeys, total_count, nil, lcm_of_divisors)
    cycle_through_rounds(new_monkeys, round + 1, total_rounds, lcm_of_divisors)
  end

  # All monkeys have thrown
  defp inspect_and_throw_items(monkey_number, monkeys, monkey_number, _, _), do: monkeys

  # Monkey has hrown all its item, switch to new monkey
  defp inspect_and_throw_items(monkey_number, monkeys, total_count, [], lcm_of_divisors) do
    inspect_and_throw_items(monkey_number + 1, monkeys, total_count, nil, lcm_of_divisors)
  end

  # start new monkey throw
  defp inspect_and_throw_items(monkey_number, monkeys, total_count, nil, lcm_of_divisors) do
    %{items: items} = Enum.at(monkeys, monkey_number)
    new_monkeys = create_new_monkey_map(monkeys, monkey_number, %{items: []})

    inspect_and_throw_items(monkey_number, new_monkeys, total_count, items, lcm_of_divisors)
  end

  # Cycle through throwing
  defp inspect_and_throw_items(
         monkey_number,
         monkeys,
         total_count,
         [item | rest],
         lcm_of_divisors
       ) do
    %{
      divisible: divisible,
      if_true: if_true,
      if_false: if_false,
      operation: operation,
      inspected_items: inspected_items
    } = Enum.at(monkeys, monkey_number)

    new_item = operate(operation, item, lcm_of_divisors)
    to_monkey = divisible_test(divisible, if_true, if_false, new_item)
    %{items: target_items} = Enum.at(monkeys, to_monkey)

    counted_monkeys =
      create_new_monkey_map(monkeys, monkey_number, %{inspected_items: inspected_items + 1})

    monkeys_with_new_items =
      create_new_monkey_map(counted_monkeys, to_monkey, %{
        items: List.insert_at(target_items, -1, new_item)
      })

    inspect_and_throw_items(
      monkey_number,
      monkeys_with_new_items,
      total_count,
      rest,
      lcm_of_divisors
    )
  end

  defp get_2_higest_inspect_counts(monkeys) do
    [first, second] =
      monkeys
      |> Enum.map(fn %{inspected_items: inspected} -> inspected end)
      |> Enum.sort()
      |> Enum.take(-2)

    first * second
  end

  # Helpers
  defp create_new_monkey_map(monkeys, monkey_number, change) do
    total_count = Enum.count(monkeys)
    monkey = Enum.at(monkeys, monkey_number)
    new_monkey = Map.merge(monkey, change)

    Enum.map(0..(total_count - 1), fn index ->
      if index == monkey_number, do: new_monkey, else: Enum.at(monkeys, index)
    end)
  end

  defp operate(%{operator: operator, x: x, y: y}, prev_value, lcm_of_divisors) do
    parsed_x =
      case x do
        "old" -> prev_value
        value -> value |> String.to_integer()
      end

    parsed_y =
      case y do
        "old" -> prev_value
        value -> value |> String.to_integer()
      end

    worry_level =
      case operator do
        "*" -> parsed_x * parsed_y
        "/" -> parsed_x / parsed_y
        "+" -> parsed_x + parsed_y
        "-" -> parsed_x - parsed_y
      end

    if lcm_of_divisors,
      do: worry_level |> round_it() |> rem(lcm_of_divisors),
      else: (worry_level / 3) |> round_it()
  end

  defp divisible_test(divisible, if_true, if_false, item) do
    if rem(item, divisible) == 0, do: if_true, else: if_false
  end

  defp round_it(number) when is_integer(number) do
    number
  end

  defp round_it(number) do
    number |> trunc()
  end
end

defmodule Day11Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/11
  """

  def read_test do
    """
    Monkey 0:
      Starting items: 79, 98
      Operation: new = old * 19
      Test: divisible by 23
        If true: throw to monkey 2
        If false: throw to monkey 3

    Monkey 1:
      Starting items: 54, 65, 75, 74
      Operation: new = old + 6
      Test: divisible by 19
        If true: throw to monkey 2
        If false: throw to monkey 0

    Monkey 2:
      Starting items: 79, 60, 97
      Operation: new = old * old
      Test: divisible by 13
        If true: throw to monkey 1
        If false: throw to monkey 3

    Monkey 3:
      Starting items: 74
      Operation: new = old + 3
      Test: divisible by 17
        If true: throw to monkey 0
        If false: throw to monkey 1
    """
  end

  def read_fixture do
    File.read!("test/11/fixture/monkey_business.txt")
  end

  test "Puzzle 1: TB" do
    test_data = read_test()

    test_result = MonkeyMachine.find_business_by_2_active_monkeys(test_data)
    assert test_result == 10605

    real_data = read_fixture()
    real_result = MonkeyMachine.find_business_by_2_active_monkeys(real_data)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: TB" do
    test_data = read_test()

    test_result = MonkeyMachine.find_business_by_2_active_monkeys_extra_worried(test_data)
    assert test_result == 2_713_310_158

    real_data = read_fixture()
    real_result = MonkeyMachine.find_business_by_2_active_monkeys_extra_worried(real_data)
    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

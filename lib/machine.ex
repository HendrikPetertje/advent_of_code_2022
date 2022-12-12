defmodule Machine do
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
  def find_business_by_2_active_monkeys(input_data) do
    input_data
    |> divide_per_instruction()
    |> instruction_to_map()
    |> cycle_through_rounds(0, 20, false)
    |> get_2_higest_inspect_counts()

    # divide per instruction
    # divide instructions in to objects
    # cycle through rounds
  end

  def find_business_by_2_active_monkeys_extra_worried(input_data) do
    input_data
    |> divide_per_instruction()
    |> instruction_to_map()
    |> cycle_through_rounds(0, 500, true)
    |> cycle_through_rounds(0, 500, true)
    |> get_2_higest_inspect_counts()

    # divide per instruction
    # divide instructions in to objects
    # cycle through rounds
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

  defp cycle_through_rounds(monkeys, total_rounds, total_rounds, _extra_worried), do: monkeys

  defp cycle_through_rounds(monkeys, round, total_rounds, extra_worried) do
    IO.inspect(round)
    total_count = Enum.count(monkeys)

    new_monkeys = inspect_and_throw_items(0, monkeys, total_count, nil, extra_worried)

    cycle_through_rounds(new_monkeys, round + 1, total_rounds, extra_worried)
  end

  # All monkeys have thrown
  defp inspect_and_throw_items(monkey_number, monkeys, monkey_number, _, _), do: monkeys

  # Monkey has hrown all its item, switch to new monkey
  defp inspect_and_throw_items(monkey_number, monkeys, total_count, [], extra_worried) do
    inspect_and_throw_items(monkey_number + 1, monkeys, total_count, nil, extra_worried)
  end

  # start new monkey throw
  defp inspect_and_throw_items(monkey_number, monkeys, total_count, nil, extra_worried) do
    IO.inspect(monkey_number)
    %{items: items} = Enum.at(monkeys, monkey_number)
    new_monkeys = create_new_monkey_map(monkeys, monkey_number, %{items: []})

    result =
      inspect_and_throw_items(monkey_number, new_monkeys, total_count, items, extra_worried)

    new_monkeys = nil

    result
  end

  # Cycle through throwing
  defp inspect_and_throw_items(monkey_number, monkeys, total_count, [item | rest], extra_worried) do
    %{
      divisible: divisible,
      if_true: if_true,
      if_false: if_false,
      operation: operation,
      inspected_items: inspected_items
    } = Enum.at(monkeys, monkey_number)

    new_item = operate(operation, item, extra_worried)
    to_monkey = divisible_test(divisible, if_true, if_false, new_item)
    %{items: target_items} = Enum.at(monkeys, to_monkey)

    counted_monkeys =
      create_new_monkey_map(monkeys, monkey_number, %{inspected_items: inspected_items + 1})

    monkeys_with_new_items =
      create_new_monkey_map(counted_monkeys, to_monkey, %{
        items: List.insert_at(target_items, -1, new_item)
      })

    result =
      inspect_and_throw_items(
        monkey_number,
        monkeys_with_new_items,
        total_count,
        rest,
        extra_worried
      )

    # Attempted cleanup
    monkeys_with_new_items = nil
    counted_monkeys = nil

    result
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

  defp operate(%{operator: operator, x: x, y: y}, prev_value, extra_worried) do
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

    if extra_worried, do: worry_level |> round_it(), else: (worry_level / 3) |> round_it()
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

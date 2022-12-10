defmodule CathodeMachine do
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
  def get_signal_strength(input_data) do
    input_data
    |> split_and_clean()
    |> perform_instructions()
  end

  def get_picture(input_data) do
    input_data
    |> split_and_clean()
    |> perform_crt()
    |> chunk_and_draw()
  end

  # Shared
  defp split_and_clean(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.reject(fn line -> line == "" end)
  end

  # Signal strength
  defp check_signal_strength(cycle, register_x, signal_strength) do
    # exactly 20 or divisible by 40 + 20
    if cycle == 20 || rem(cycle + 20, 40) == 0,
      do: cycle * register_x + signal_strength,
      else: signal_strength
  end

  defp perform_instructions(
         instructions,
         cycle \\ 1,
         register_x \\ 1,
         signal_strength \\ 0
       )

  defp perform_instructions(["noop" | rest], cycle, register_x, signal_strength) do
    # Check for interval and set new signal_strength
    new_signal_strength = check_signal_strength(cycle, register_x, signal_strength)

    perform_instructions(rest, cycle + 1, register_x, new_signal_strength)
  end

  defp perform_instructions(["addx " <> value | rest], cycle, register_x, signal_strength) do
    first_cycle_signal_strength = check_signal_strength(cycle, register_x, signal_strength)

    # second tick
    second_cycle = cycle + 1

    second_cycle_signal_strength =
      check_signal_strength(second_cycle, register_x, first_cycle_signal_strength)

    new_register_x = String.to_integer(value) + register_x

    perform_instructions(rest, second_cycle + 1, new_register_x, second_cycle_signal_strength)
  end

  defp perform_instructions([], _, _, signal_strength), do: signal_strength

  # get_image
  defp draw_sprite(cycle, register_x, sprite) do
    calc_register_x =
      cond do
        cycle > 240 -> register_x + 240
        cycle > 200 -> register_x + 200
        cycle > 160 -> register_x + 160
        cycle > 120 -> register_x + 120
        cycle > 80 -> register_x + 80
        cycle > 40 -> register_x + 40
        true -> register_x
      end

    char =
      if cycle == calc_register_x ||
           cycle == calc_register_x + 1 ||
           cycle == calc_register_x + 2,
         do: "#",
         else: " "

    sprite
    |> String.codepoints()
    |> put_in([Access.at(cycle - 1)], char)
    |> Enum.join()
  end

  defp perform_crt(
         instructions,
         cycle \\ 1,
         register_x \\ 1,
         sprite \\ String.duplicate(".", 240)
       )

  defp perform_crt(["addx " <> value | rest], cycle, register_x, sprite) do
    first_cycle_sprite = draw_sprite(cycle, register_x, sprite)

    # second tick
    second_cycle = cycle + 1

    second_cycle_sprite = draw_sprite(second_cycle, register_x, first_cycle_sprite)

    new_register_x = String.to_integer(value) + register_x

    # perform_instructions(rest, second_cycle + 1, new_register_x, second_cycle_signal_strength)
    perform_crt(rest, second_cycle + 1, new_register_x, second_cycle_sprite)
  end

  defp perform_crt(["noop" | rest], cycle, register_x, sprite) do
    # Check for interval and set new signal_strength
    new_sprite = draw_sprite(cycle, register_x, sprite)

    perform_crt(rest, cycle + 1, register_x, new_sprite)
  end

  defp perform_crt([], _, _, sprite), do: sprite

  defp chunk_and_draw(sprite) do
    sprite
    |> String.codepoints()
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end
end

defmodule Day10Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/10
  """

  def read_test do
    """
    noop
    addx 3
    addx -5
    """

    File.read!("test/10/fixture/test_instructions.txt")
  end

  def read_fixture do
    File.read!("test/10/fixture/cpu_instructions.txt")
  end

  test "Puzzle 1: TB" do
    test_data = read_test()

    test_result = CathodeMachine.get_signal_strength(test_data)
    assert test_result == 13140

    real_data = read_fixture()
    real_result = CathodeMachine.get_signal_strength(real_data)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: TB" do
    test_data = read_test()

    test_result = CathodeMachine.get_picture(test_data)
    IO.puts("\n#{test_result}")

    real_data = read_fixture()
    real_result = CathodeMachine.get_picture(real_data)
    IO.puts(" Puzzle 2 answer:")
    IO.puts("\n#{real_result}")
  end
end

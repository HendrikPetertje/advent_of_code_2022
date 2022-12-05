defmodule GenerateDay do
  def run() do
    check_input()

    [day, module, whitty_name] = System.argv()

    padded_day = String.pad_leading(day, 2, "0")
    path = "#{File.cwd!}/test/#{padded_day}"
    File.mkdir_p!("#{path}/fixture")
    File.write!("#{path}/fixture/#{whitty_name}.txt", "\n")

    test_contents = test_file(module, day, padded_day, whitty_name)
    File.write!("#{path}/day_#{day}_test.exs", test_contents)
  end

  defp check_input() do
    if System.argv() |> Enum.count != 3, do: throw("Please call this file with day_gen.ex day-number ModuleName whity-name")
  end

  defp test_file(module, day, padded_day, whitty_name) do
    """
    defmodule #{module} do

      @moduledoc \"\"\"
      module-wide docs
      \"\"\"

      @doc \"\"\"
      What does this do?

      ## Parameters

        - input_data: newline-split records of something.

      ## Examples

          iex> example(input_data)
          TBD

      \"\"\"
      def do_something(input_data), do: input_data
    end

    defmodule Day#{day}Test do
      use ExUnit.Case

      @moduledoc \"\"\"
      Assignment: https://adventofcode.com/2022/day/#{day}
      \"\"\"

      def read_test do
        \"\"\"
        TEST_DATA_HERE
        \"\"\"
      end

      def read_fixture do
        File.read!("test/#{padded_day}/fixture/#{whitty_name}.txt")
      end

      test "Puzzle 1: TB" do
        test_data = read_test()

        test_result = #{module}.do_something(test_data)
        assert test_result == "TBD"

        real_data = read_fixture()
        real_result = ModuleName.do_something(real_data)
        IO.puts(" Puzzle 1 answer: << \#{real_result} >>")
      end

      @tag :skip
      test "Puzzle 2: TBD" do
        # test_data = read_test()

        # test_result = ModuleName.do_something(test_data)
        # assert test_result == "TBD"

        # real_data = read_fixture()
        # real_result = ModuleName.do_something(test_data)
        # IO.puts(" Puzzle 1 answer: << \#{real_result} >>")
      end
    end
    """
  end
end

GenerateDay.run()


defmodule FileSystemMachine do
  @moduledoc """
  module-wide docs
  """

  @doc """
  Gets the sum of all dirs that have less than 100_000 data

  ## Parameters

    - input_data: newline-split records of terminal commands.

  ## Examples

      iex> get_sum_of_dirs_under_100000(input_data)
      1000

  """
  def get_sum_of_dirs_under_100000(input_data) do
    input_data
    |> divide_per_command()
    |> divide_command_and_output()
    |> process_commands()
    |> sum_dirs_under_100000()
  end

  @doc """
  Finds the size of the directory to remove

  ## Parameters

    - input_data: newline-split records of terminal commands.

  ## Examples

      iex> find_size_of_dir_to_remove(input_data)
      100000

  """
  def find_size_of_dir_to_remove(input_data) do
    input_data
    |> divide_per_command()
    |> divide_command_and_output()
    |> process_commands()
    |> find_size_of_removable_dir()
  end

  # 1
  defp divide_per_command(input_data) do
    input_data
    |> String.split("\n$ ")
    # That first one is a bit pesky, so we need to clear it manually
    |> Enum.map(fn cmd -> cmd |> String.replace("$ ", "") end)
  end

  # 2
  defp divide_command_and_output(commands) do
    commands
    |> Enum.map(fn input ->
      [cmd | output] =
        input
        |> String.split("\n")
        |> Enum.reject(fn output -> output == "" end)

      %{cmd: cmd, out: output}
    end)
  end

  # 3 Define some defaults
  defp process_commands(commands, obj \\ %{}, current_path \\ "root")

  # 3 Process LS commands
  defp process_commands([%{cmd: "ls", out: out} | rest], obj, current_path) do
    output =
      out
      |> Enum.map(fn item -> item |> String.split(" ") end)
      |> Enum.reject(fn [dir_or_size, _] -> dir_or_size == "dir" end)
      |> Enum.map(fn [size, _] -> size |> String.to_integer() end)
      |> Enum.sum()

    path = current_path |> String.split("/")

    new_obj = insert_size_at_path(path, output, obj)

    process_commands(
      rest,
      new_obj,
      current_path
    )
  end

  # 3 Process cd commands
  defp process_commands([%{cmd: "cd " <> path} | rest], obj, current_path) do
    new_path =
      case path do
        ".." -> current_path |> String.split("/") |> Enum.drop(-1) |> Enum.join("/")
        "/" -> "root"
        new_dir -> current_path <> "/" <> new_dir
      end

    process_commands(
      rest,
      obj,
      new_path
    )
  end

  # 3 process end
  defp process_commands([], obj, _), do: obj

  # Update object helpers
  defp insert_size_at_path([], _, obj), do: obj

  defp insert_size_at_path(path, output, obj) do
    new_path = path |> Enum.join("/")
    pre_existing = obj[new_path] || 0

    new_obj = Map.merge(obj, %{new_path => pre_existing + output})

    insert_size_at_path(
      Enum.drop(path, -1),
      output,
      new_obj
    )
  end

  # 4 sum it all
  defp sum_dirs_under_100000(input) do
    input
    |> Map.keys()
    |> Enum.map(fn key ->
      input[key]
    end)
    |> Enum.reject(fn value -> value > 100_000 end)
    |> Enum.sum()
  end

  # 4 find size of dir to remove
  defp find_size_of_removable_dir(%{"root" => size_used} = input) do
    disk_size = 70_000_000
    size_required = 30_000_000
    free_size = disk_size - size_used
    size_to_free = size_required - free_size

    input
    |> Map.keys()
    |> Enum.map(fn key ->
      input[key]
    end)
    |> Enum.reject(fn item -> size_to_free > item end)
    |> Enum.sort()
    |> List.first()
  end
end

defmodule Day7Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/7
  """

  def read_test do
    """
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
    """
  end

  def read_fixture do
    File.read!("test/07/fixture/command_history.txt")
  end

  test "Puzzle 1: get total size of dirs smaller than 100000" do
    test_data = read_test()

    test_result = FileSystemMachine.get_sum_of_dirs_under_100000(test_data)
    assert test_result == 95437

    real_data = read_fixture()
    real_result = FileSystemMachine.get_sum_of_dirs_under_100000(real_data)
    IO.puts(" Puzzle 1 answer: << #{real_result} >>")
  end

  test "Puzzle 2: Find the dir to remove to free up enough space" do
    test_data = read_test()

    test_result = FileSystemMachine.find_size_of_dir_to_remove(test_data)
    assert test_result == 24_933_642

    real_data = read_fixture()
    real_result = FileSystemMachine.find_size_of_dir_to_remove(real_data)
    IO.puts(" Puzzle 2 answer: << #{real_result} >>")
  end
end

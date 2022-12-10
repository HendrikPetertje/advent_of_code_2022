defmodule MapInspector do
  def map_out(positions, number_of_y, number_of_x) do
    1..number_of_y
    |> Enum.map(fn row ->
      generate_row(row - 1, number_of_x, positions)
    end)
    |> Enum.join("\n")
    |> IO.puts()

    IO.puts("")
  end

  defp generate_row(y, number_of_x, positions) do
    1..number_of_x
    |> Enum.map(fn pos ->
      something_at?([pos - 1, y], positions)
    end)
    |> Enum.join("")
  end

  defp something_at?(_, []), do: "."
  defp something_at?(location, [[name, location] | _rest]), do: name
  defp something_at?(location, [_ | rest]), do: something_at?(location, rest)
end

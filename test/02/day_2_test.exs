defmodule RockPaperScissorsMachine do
  @moduledoc """
  This module calculates scores from a rock-paper-sciossors game in two different ways

  In the first method a lit of games is provided where the player has to choose a
  specific move (a and x: rock, b and y: paper, c and Z: scissors)

  In the second method the game is instead rigged and x means lose, b, draw and c win
  """

  @doc """
  Return the total score for player from playing rock-paper-sciossors where:
  A & X are Rock
  B & Y are Paper
  C & Z are scissor
  """
  def total_score_from_games(list_of_games) do
    list_of_games
    |> list_to_matches()
    |> matches_to_moves()
    |> moves_to_scores()
    |> player_total_points()
  end

  @doc """
  Return the total score for player from playing rock-paper-sciossors where:
  A is Rock
  B is Paper
  C is scissor

  X is Lose
  Y is Draw
  Z is Win
  """
  def total_score_from_rigging(list_of_games) do
    list_of_games
    |> list_to_matches()
    |> matches_to_rigged_moves()
    |> moves_to_scores()
    |> player_total_points()
  end

  # Step 1 split apart
  defp list_to_matches(string_of_games) do
    string_of_games
    |> String.split("\n")
    |> Enum.reject(fn value -> value == "" end)
    |> Enum.map(fn value -> value |> String.split(" ") end)
  end

  # Step 2, read to readable moves for Act 1
  defp matches_to_moves(list_of_games) do
    list_of_games
    |> Enum.map(fn [a, b] ->
      [letter_to_move(a), letter_to_move(b)]
    end)
  end

  defp letter_to_move("A"), do: :rock
  defp letter_to_move("B"), do: :paper
  defp letter_to_move("C"), do: :scissor
  defp letter_to_move("X"), do: :rock
  defp letter_to_move("Y"), do: :paper
  defp letter_to_move("Z"), do: :scissor

  # Step 2, rigging the game instead for Act 2
  defp matches_to_rigged_moves(list_of_games) do
    list_of_games
    |> Enum.map(fn [a, b] ->
      their_move = letter_to_move(a)
      our_move = letter_to_rigged_move(their_move, b)
      [their_move, our_move]
    end)
  end

  # Lose
  defp letter_to_rigged_move(:rock, "X"), do: :scissor
  defp letter_to_rigged_move(:paper, "X"), do: :rock
  defp letter_to_rigged_move(:scissor, "X"), do: :paper
  # Draw
  defp letter_to_rigged_move(their_move, "Y"), do: their_move
  # Win
  defp letter_to_rigged_move(:rock, "Z"), do: :paper
  defp letter_to_rigged_move(:paper, "Z"), do: :scissor
  defp letter_to_rigged_move(:scissor, "Z"), do: :rock

  # Step 3
  defp moves_to_scores(list_of_objects) do
    list_of_objects |> Enum.map(&get_win_or_loss/1)
  end

  defp get_win_or_loss([:rock, :rock]), do: %{result: :draw, score: 3, style: 1}
  defp get_win_or_loss([:rock, :paper]), do: %{result: :win, score: 6, style: 2}
  defp get_win_or_loss([:rock, :scissor]), do: %{result: :loss, score: 0, style: 3}
  defp get_win_or_loss([:paper, :rock]), do: %{result: :loss, score: 0, style: 1}
  defp get_win_or_loss([:paper, :paper]), do: %{result: :draw, score: 3, style: 2}
  defp get_win_or_loss([:paper, :scissor]), do: %{result: :win, score: 6, style: 3}
  defp get_win_or_loss([:scissor, :rock]), do: %{result: :win, score: 6, style: 1}
  defp get_win_or_loss([:scissor, :paper]), do: %{result: :loss, score: 0, style: 2}
  defp get_win_or_loss([:scissor, :scissor]), do: %{result: :draw, score: 3, style: 3}

  # Step 4: Get the total score for player
  defp player_total_points(results) do
    results
    |> Enum.map(fn %{score: score, style: style} -> score + style end)
    |> Enum.sum()
  end
end

defmodule Day2Test do
  use ExUnit.Case

  @moduledoc """
  Assignment: https://adventofcode.com/2022/day/2
  """

  def read_test do
    """
    A Y
    B X
    C Z
    """
  end

  def read_fixture do
    File.read!("test/02/fixture/game_list.txt")
  end

  test "Puzzle 1: Total score by player" do
    test_games = read_test()

    result = RockPaperScissorsMachine.total_score_from_games(test_games)
    assert result == 15

    real_games = read_fixture()
    result = RockPaperScissorsMachine.total_score_from_games(real_games)
    IO.puts(" Puzzle 1 answer: << #{result} >>")
  end

  test "Puzzle 2: Total score by rigging player" do
    test_games = read_test()

    result = RockPaperScissorsMachine.total_score_from_rigging(test_games)
    assert result == 12

    real_games = read_fixture()
    result = RockPaperScissorsMachine.total_score_from_rigging(real_games)
    IO.puts(" Puzzle 2 answer: << #{result} >>")
  end
end

defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
    assert all_chars?(game.letters)
  end

  test "state isn't changed for :won or :lost game" do
    for state <- [ :won, :lost ] do
      game = Game.new_game() |> Map.put(:game_state, state)
      assert ^game = Game.make_move(game, "x")
    end
  end

  test "first occurrence of letter is not already used" do
    game = Game.new_game()
    game = Game.make_move(game, "x")
    assert game.game_state != :already_used
  end

  test "second occurrence of letter is  already used" do
    game = Game.new_game()
    game = Game.make_move(game, "x")
    game = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "a good guess is recognixed" do
    game = Game.new_game("wtf")
    game = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a good word is won" do
    game = Game.new_game("wtf")
    game = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
    game = Game.make_move(game, "t")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
    game = Game.make_move(game, "f")
    assert game.game_state == :won
    assert game.turns_left == 7
  end

  test "a bad guess is recognixed" do
    game = Game.new_game("wtf")
    game = Game.make_move(game, "z")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "seven bad guesses is a loss" do
    game = Game.new_game("w")
    game = Game.make_move(game, "a")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
    game = Game.make_move(game, "b")
    assert game.game_state == :bad_guess
    assert game.turns_left == 5
    game = Game.make_move(game, "c")
    assert game.game_state == :bad_guess
    assert game.turns_left == 4
    game = Game.make_move(game, "d")
    assert game.game_state == :bad_guess
    assert game.turns_left == 3
    game = Game.make_move(game, "e")
    assert game.game_state == :bad_guess
    assert game.turns_left == 2
    game = Game.make_move(game, "f")
    assert game.game_state == :bad_guess
    assert game.turns_left == 1
    game = Game.make_move(game, "g")
    assert game.game_state == :lost
    assert game.turns_left == 0
  end

  test "comprehesion loss" do
    moves = [
      {"w", :good_guess}, 
      {"i", :good_guess}, 
      {"b", :good_guess}, 
      {"l", :good_guess}, 
      {"e", :won}
    ]

    game = Game.new_game("wibble")
    
    Enum.reduce(moves, game, fn ({guess, state}, new_game) ->
      new_game = Game.make_move(new_game, guess)
      assert new_game.game_state == state
      new_game
    end)
  end

  test "bad guess is recognized" do
    new_game = Game.new_game |> Game.make_move("A")
    assert new_game.game_state == :invalid_guess
    new_game = Game.new_game |> Game.make_move("ab")
    assert new_game.game_state == :invalid_guess
  end

  defp all_chars?(letters) do 
    letters |> Enum.all?(fn(c) -> c >= "a" && c <= "z" end)
  end 

end

defmodule Hangman.Game do

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  def new_game(word) do 
    %Hangman.Game{
      letters: word |> String.codepoints
    }
  end

  def new_game() do
    Dictionary.random_word()
    |>  new_game
  end

  def make_move(game = %{ game_state: state}, _guess) when state in [:won, :lost] do
    game
    |> return_with_tally()
  end

  def make_move(game, guess) do
    accept_move(game, guess, MapSet.member?(game.used, guess), valid_guess(guess))
    |> return_with_tally()
  end

  defp return_with_tally(game) do
    { game, tally(game) }
  end

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: reveal_letters(game.letters, game.used)
    }
  end

  defp reveal_letters(letters, used) do 
    letters
    |> Enum.map(fn (letter) -> reveal(letter, MapSet.member?(used, letter)) end)
  end

  defp reveal(letter, _is_used = true), do: letter

  defp reveal(letter, _not_used), do: "_"

  defp accept_move(game, _guess, _already_guessed = true, _whatever) do
    game |> Map.put(:game_state, :already_used )
  end

  defp accept_move(game, _guess, _not_already_guessed, _valid_guess = false) do
    game |> Map.put(:game_state, :invalid_guess )
  end

  defp accept_move(game, guess, _not_already_guessed, _valid_guess) do
    game |> 
      Map.put(:used, game.used |> MapSet.put(guess)) |> 
      score_guess(Enum.member?(game.letters, guess))
  end

  defp score_guess(game, _good_guess = true) do 
    new_state = MapSet.new(game.letters)
    |> MapSet.subset?(game.used) 
    |> has_won?()
    game |> Map.put(:game_state, new_state)
  end

  defp score_guess(game = %{ turns_left: 1}, _not_good_guess) do
    %{ game |
      game_state: :lost,
      turns_left: 0
    }
  end

  defp score_guess(game = %{ turns_left: turns_left }, _not_good_nuess) do
    %{ game | 
        turns_left: turns_left - 1,
        game_state: :bad_guess
      }
  end

  defp has_won?(true), do: :won

  defp has_won?(false), do: :good_guess

  defp valid_guess(guess) do 
    String.length(guess) == 1 && String.downcase(guess) == guess
  end

end

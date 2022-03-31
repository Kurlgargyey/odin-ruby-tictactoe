# frozen_string_literal: true

# this class keeps score and handles the moves it's being passed by the Players
class Game
  def initialize
    @scores = Hash.new(0)
    self.board = Array.new(3) { Array.new(3) }
    puts 'Please enter your name, Player 1:'
    @player1 = Player.new(gets.chomp)
    puts 'Please enter your name, Player 2:'
    @player2 = Player.new(gets.chomp)
  end

  def run_match
    turn = 1
    active_player = @player1
    passive_player = @player2
    until turn == 10
      puts "Turn #{turn}:"
      process_turn(active_player, passive_player)
      break if active_player.winner?

      turn += 1
      active_player, passive_player = passive_player, active_player
    end
    game_over(turn, active_player, passive_player)
  end

  protected

  attr_accessor :board

  def draw_move(player, move)
    case player
    when @player1
      board[move[0] - 1][move[1] - 1] = 'X'
    when @player2
      board[move[0] - 1][move[1] - 1] = 'O'
    end
  end

  def process_turn(active_player,passive_player)
    puts "It's #{active_player.name}'s turn! Pick a field!"
    move = active_player.make_move(passive_player)
    draw_move(active_player, move)
    active_player.moves.push(active_player.points_map[move[0] - 1][move[1] - 1])
  end

  def clear_game
    @player1.moves.clear
    @player2.moves.clear
    self.board = Array.new(3){ Array.new(3) }
  end

  def reinitialize
    puts 'Do you want to play again? Y/N'
    ans = gets.chomp
    sleep 2
    if ans.casecmp('y').zero?
      clear_game
      puts "Okay! Let's go again!"
      run_match
    else
      puts 'Alright! See you and have a great day!'
    end
  end

  def game_over(turn, winner, loser)
    puts 'There was no winner by turn 9.' if turn == 10
    @scores[winner] += 1
    puts "Congratulations! #{winner.name} won!"
    puts "The score is #{@scores[winner]} for #{winner.name} and #{@scores[loser]} for #{loser.name}."
    reinitialize
  end
end

# this class takes moves from the player, validates them, and passes them to the Game class
class Player
  attr_reader :name, :points_map
  attr_accessor :moves

  def initialize(name)
    @name = name
    @moves = []
    @points_map = [
      [8, 3, 4],
      [1, 5, 9],
      [6, 7, 2]
    ]
  end

  def make_move(opponent)
    move = input_move
    if opponent.check_moves(move) || check_moves(move)
      puts 'That field has already been chosen. Choose again.'
      make_move(opponent)
    else
      move
    end
  end

  def winner?
    moves.combination(3) do |triplet|
      return true if triplet.sum == 15
    end
    false
  end

  protected

  def check_moves(move)
    moves.include?(self.points_map[move[0] - 1][move[1] - 1])
  end

  private

  def input_move
    input = +''
    until /^[1-3],\s[1-3]$/.match(input)
      puts 'Please select a field (enter its board coordinates in the format \"x, y\"):'
      input = gets.chomp
    end
    move = input.split(', ')
    move.map(&:to_i)
  end
end

match = Game.new
match.run_match

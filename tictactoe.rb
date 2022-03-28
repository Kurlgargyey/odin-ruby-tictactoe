# frozen_string_literal: true

class Game
  @@scores = Hash.new(0)

  def initialize()
    self.board = Array.new(3){Array.new(3)}
    puts "Please enter your name, Player 1:"
    @player1 = Player.new(gets.chomp)
    puts "Please enter your name, Player 2:"
    @player2 = Player.new(gets.chomp)
  end

  def run_match
    turn = 1
    active_player = @player1
    passive_player = @player2
    until turn == 10
      puts "Turn #{turn}:"
      process_turn(active_player, passive_player)
      if active_player.winner?()
        break
      end
      turn +=1
      active_player, passive_player = passive_player, active_player
    end
    if turn == 10
      puts "There was no winner by turn 9."
    end
    @@scores[active_player] += 1
    puts "Congratulations! #{active_player.name} won!"
    puts "The score is #{@@scores[active_player]} for #{active_player.name} to #{@@scores[passive_player]} for #{passive_player.name}."
  end

  protected
  attr_accessor :board

  def process_turn (active_player,passive_player)
    puts "It's #{active_player.name}'s turn! Pick a field!"
    move = active_player.make_move(passive_player)
    case active_player
    when @player1
      self.board[move[0]-1][move[1]-1] = 'X'
    when @player2
      self.board[move[0]-1][move[1]-1] = 'O'
    end
    active_player.moves.push(active_player.class.points_map[move[0]-1][move[1]-1])
  end


end

class Player
  attr_reader :name
  attr_accessor :moves
  @@points_map = [
    [8, 3, 4],
    [1, 5, 9],
    [6, 7, 2]
  ]

  def initialize(name)
    @name = name
    @moves = []
  end

  def make_move(opponent)
    move = get_move()
    unless opponent.moves.include?(@@points_map[move[0]-1][move[1]-1]) || self.moves.include?(@@points_map[move[0]-1][move[1]-1])
      return move
    else
      puts "That field has already been chosen. Choose again."
      make_move(opponent)
    end
  end

  def winner?()
    self.moves.combination(3) do |triplet| 
      if triplet.sum == 15
        return true
      end
    end
    false
  end

  protected

  def self.points_map
    @@points_map
  end

  private
  def get_move
    input = +""
    while !/^[1-3],\s[1-3]$/.match(input)
      puts "Please select a field (enter its board coordinates in the format \"x, y\"):"
      input = gets.chomp
    end
    move = input.split(", ")
    move.map {|e| e.to_i}
  end
  
end

match = Game.new()
match.run_match
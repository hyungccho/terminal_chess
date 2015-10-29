require_relative 'board'
require_relative 'player'
require_relative './modules/saveable'
require 'byebug'

class Game
  include Saveable

  attr_reader :board
  
  def initialize(player1, player2)
    @board = Board.new
    @players = [player1, player2]
    @current_player = @players.first
  end

  def play
    puts "Enter Player 1 name:"
    @players[0].name = gets.chomp
    @players[0].color = :white

    puts "Enter Player 2 name:"
    @players[1].name = gets.chomp
    @players[1].color = :black

    @board.display.render(@current_player.color)
    puts "New Game!"
    puts "Press Control + S at any time to save the game."
    puts "#{@players[0].name} is white"
    puts "#{@players[1].name} is black"
    puts "#{@current_player.name} goes first!"
    sleep 3

    until won?
      take_turn
      switch_players!
    end
    puts "#{@players.first.name} is the winner!"
  end

  private

    def switch_players!
      @players.rotate!(1)
      @current_player = @players.first
    end

    def won?
      if board.checkmate?(:white) || board.checkmate?(:black)
        @players.shift
        true
      else
        false
      end
    end

    def take_turn
      begin
        @board.make_move(@current_player.color)
      rescue WrongPlayerError
        puts "Wrong color!"
        retry
      rescue InvalidMoveError
        puts "Invalid Move!"
        retry
      end
    end
end

if __FILE__ == $PROGRAM_NAME
  player_one = Player.new
  player_two = Player.new

  game = Game.new(player_one, player_two)
  game.play
end

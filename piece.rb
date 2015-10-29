require_relative './modules/slideable'
require_relative './modules/steppable'

class Piece

  attr_reader :color
  attr_accessor :pos

  def initialize(color, pos, board)
    @color = color
    @pos = pos
    @board = board
  end

  def same_color?(piece)
    self.color == piece.color
  end

  def white?
    self.color == :white
  end

  def black?
    self.color == :black
  end

  def dup(board)
    self.class.new(@color, @pos.dup, board)
  end

  def valid_moves(color)
    result = []

    self.get_possible_moves.each do |move|
      new_board = @board.dup
      new_board.make_move!(@pos, move, color)
      result << move unless new_board.in_check?(color)
    end
    result
  end

end

class Rook < Piece
  include Slideable

  def available_directions
    [:up, :down, :left, :right]
  end

  def to_s
    @color == :white ? " ♜ " : " ♜ ".colorize(:black)
  end
end

class Bishop < Piece
  include Slideable

  def available_directions
    [:upright, :upleft, :downright, :downleft]
  end

  def to_s
    @color == :white ? " ♝ " : " ♝ ".colorize(:black)
  end
end

class Queen < Piece
  include Slideable

  def available_directions
    [:up, :down, :left, :right, :upright, :upleft, :downright, :downleft]
  end

  def to_s
    @color == :white ? " ♛ " : " ♛ ".colorize(:black)
  end
end

class Knight < Piece
  def get_possible_moves
    available_directions = [[2, -1], [2, 1], [-2, -1], [-2, 1], [1, -2], [1, 2], [-1, -2], [-1, 2]]

    result = []
    available_directions.each do |change|
      new_pos = [change[0] + @pos[0], change[1] + @pos[1]]
      result << new_pos if @board.valid_move?(@pos, new_pos)
    end
    result
  end

  def to_s
    @color == :white ? " ♞ " : " ♞ ".colorize(:black)
  end
end

class King < Piece
  include Steppable

  def available_directions
    [:up, :down, :left, :right, :upright, :upleft, :downright, :downleft]
  end

  def to_s
    @color == :white ? " ♚ " : " ♚ ".colorize(:black)
  end
end

class Pawn < Piece
  def initialize(color, pos, board)
    super
    @available_directions = []
  end

  DIRECTIONS = { up: [-1, 0],
                 down: [1, 0],
                 left: [0, -1],
                 right: [0, 1],
                 upright: [-1, 1],
                 upleft: [-1, -1],
                 downright: [1, 1],
                 downleft: [1, -1] }

  def determine_moves
    if @color == :black
      @available_directions << [1, 0] unless @board[[@pos[0] + 1, @pos[1]]].is_a?(Piece)
    elsif @color == :white
      @available_directions << [-1, 0] unless @board[[@pos[0] - 1, @pos[1]]].is_a?(Piece)
    end

    if in_original_position?(@color)
      if @color == :black
        @available_directions << [2, 0] unless @board[[@pos[0] + 1, @pos[1]]].is_a?(Piece)
      elsif @color == :white
        @available_directions << [-2, 0] unless @board[[@pos[0] - 1, @pos[1]]].is_a?(Piece)
      end
    end
    check_diagonals(@color)
  end

  def in_original_position?(color)
    if color == :black && @pos[0] == 1
      return true
    elsif color == :white && @pos[0] == 6
      return true
    end
    false
  end

  def check_diagonals(color)
    possibles = []
    if color == :black
      possibles = [:downright, :downleft]

      possibles.each do |dir|
        pos = [DIRECTIONS[dir][0] + @pos[0], DIRECTIONS[dir][1] + @pos[1]]
        @available_directions << DIRECTIONS[dir] if @board.valid_move?(@pos, pos) && @board[pos].color == :white
      end
    elsif color == :white
      possibles = [:upright, :upleft]

      possibles.each do |dir|
        pos = [DIRECTIONS[dir][0] + @pos[0], DIRECTIONS[dir][1] + @pos[1]]
        @available_directions << DIRECTIONS[dir] if @board.valid_move?(@pos, pos) && @board[pos].color == :black
      end
    end
  end

  def get_possible_moves
    determine_moves

    result = []
    @available_directions.each do |change|
      new_pos = [change[0] + @pos[0], change[1] + @pos[1]]
      result << new_pos
    end

    @available_directions = []
    result
  end

  def to_s
    @color == :white ? " ♟ " : " ♟ ".colorize(:black)
  end
end

class EmptySquare
  def to_s
    "   "
  end

  def color
    nil
  end

  def same_color?(arg)
    false
  end

  def white?
    false
  end

  def black?
    false
  end

  def dup(board)
    EmptySquare.new
  end

  def valid_moves(color)
    []
  end
end

class InvalidMoveError < StandardError
end

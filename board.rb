require_relative 'display'
require_relative 'piece'

class Board
  include Cursorable

  attr_reader :display, :grid, :black_pieces, :white_pieces

  def initialize(setup = true)
    @grid = Array.new(8) { Array.new(8) { EmptySquare.new } }
    @display = Display.new(self)
    @white_pieces = []
    @black_pieces = []
    populate_board if setup
    update_existing_pieces
  end

  def make_move(color)
    from, to = @display.take_input(color)
    raise WrongPlayerError if color != self[from].color

    if self[from].valid_moves(color).include?(to)
      if valid_move?(from, to)
        make_move!(from, to, color)
      end
    else
      raise InvalidMoveError
    end
    promote_pawn
  end

  def make_move!(from, to, color)
    self[to] = self[from]
    self[to].pos = to
    self[from] = EmptySquare.new
    update_existing_pieces
  end

  def dup
    new_board = Board.new(false)
    self.grid.each_with_index do |row, r|
      row.each_with_index do |node, c|
        new_board.grid[r][c] = node.dup(new_board)
      end
    end
    new_board
  end

  def in_check?(color)
    king_pos = find_king(color)
    if color == :black
      @white_pieces.each do |piece|
        piece.get_possible_moves.each do |pos|
          return true if king_pos == pos
        end
      end
    else
      @black_pieces.each do |piece|
        piece.get_possible_moves.each do |pos|
          return true if king_pos == pos
        end
      end
    end
    false
  end

  def checkmate?(color)
    return false unless in_check?(color)

    case color
    when :black
      @black_pieces.all? { |piece| piece.valid_moves(:black).count == 0 }
    when :white
      @white_pieces.all? { |piece| piece.valid_moves(:white).count == 0 }
    end
  end

  def valid_move?(from, to)
    in_bounds?(to) && !self[from].same_color?(self[to]) ? true : false
  end

  def in_bounds?(pos)
    row, col = pos
    row.between?(0, 7) && col.between?(0, 7) ? true : false
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @grid[row][col] = value
  end

  private

    def update_existing_pieces
      @white_pieces = []
      @black_pieces = []

      @grid.each do |row|
        row.each do |node|
          if node.white?
            @white_pieces << node
          elsif node.black?
            @black_pieces << node
          end
        end
      end
    end

    def find_king(color)
      pos_of_king = []
      @grid.each_with_index do |row, r|
        row.each_with_index do |node, c|
          pos_of_king = [r, c] if node.is_a?(King) && node.color == color
        end
      end

      pos_of_king
    end

    def promote_pawn
      promotion = []
      white = self.grid[0].select { |piece| piece.is_a?(Pawn) && piece.color == :white }
      black = self.grid[7].select { |piece| piece.is_a?(Pawn) && piece.color == :black }

      promotion = white + black
      promotion.each do |piece|
        self.grid[piece.pos[0]][piece.pos[1]] = Queen.new(piece.color, piece.pos, self)
      end
    end

    def populate_board
      #populate pieces
      pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
      colors = [:black, :white]
      [0, 7].each_with_index do |i, k|
        (0..7).each do |j|
          @grid[i][j] = pieces[j].new(colors[k], [i, j], self)
        end
      end

      #populate Pawns
      @grid[1].length.times do |i|
        @grid[1][i] = Pawn.new(:black, [1, i], self)
      end

      @grid[6].length.times do |i|
        @grid[6][i] = Pawn.new(:white, [6, i], self)
      end
    end
end

class WrongPlayerError < StandardError
end

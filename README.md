#Terminal Chess

Uses modules, inheritance, and `STDIN` & `STDOUT` manipulation to create a fully functional (and colored!) terminal game.

##Cursorable

This module captures player input to create a keyboard controlled game.

````ruby
...
def read_char
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return input
end

def handle_key(key)
  case key
  when :up
    update_pos(MOVES[:up])
  when :down
    update_pos(MOVES[:down])
  when :left
    update_pos(MOVES[:left])
  when :right
    update_pos(MOVES[:right])
  when :return
    select_tile
  when :ctrl_c
    exit
  when :ctrl_s
    save_game
  end
end
...
````

This module reads the character code that comes into `STDIN` and dynamically responds using a switch statement.

##Slideable / Steppable

An interesting phase in creating Chess was definitely the piece logic. Ironically enough, the pawn (weakest piece) has the most logic involved, but overall there were two types of pieces. Sliding pieces, and stepping pieces. I created two parent classes that passed down class methods to its children.

````ruby
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
````

Using multiple validity checks such as `get_possible_moves`, I was able to program valid moves and available moves, etc.

##Check and Checkmate

I kept track of pieces and looped through for their available moves before each player's turn. If there were no more available positions, that meant they were in `checkmate`. If the king's position was in the array of available moves for the opposing player, that meant check.

````ruby
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
````

#Running The Game

Clone the repo and navigate to the folder. In the terminal, type in `$ ruby game.rb`, and it'll automatically start.

Controls are as follows:
[Up arrow, Down arrow, Left Arrow, Right Arrow] to move targetted node.
[Enter] to select/deselect piece.

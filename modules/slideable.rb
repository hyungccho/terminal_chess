module Slideable
  DIRECTIONS = { up: [0, -1],
                 down: [0, 1],
                 left: [-1, 0],
                 right: [1, 0],
                 upright: [1, -1],
                 upleft: [-1, -1],
                 downright: [1, 1],
                 downleft: [-1, 1] }

  def get_possible_moves
    result = []

    available_directions.each do |dir|
      current_pos = @pos
      new_pos = [@pos[0] + DIRECTIONS[dir][0], @pos[1] + DIRECTIONS[dir][1]]

      while @board.valid_move?(current_pos, new_pos)
        result << new_pos
        current_pos = new_pos
        new_pos = [current_pos[0] + DIRECTIONS[dir][0], current_pos[1] + DIRECTIONS[dir][1]]
      end
    end
    result
  end
end

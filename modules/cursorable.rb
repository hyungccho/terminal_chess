require 'io/console'

module Cursorable
  KEYMAP = {  "\e[A" => :up,
              "\e[B" => :down,
              "\e[C" => :right,
              "\e[D" => :left,
              "\u0003" => :ctrl_c,
              "\r" => :return }

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

  MOVES = { up: [-1, 0],
            down: [1, 0],
            left: [0, -1],
            right: [0, 1] }

  def get_input
    input = read_char
    key = KEYMAP[input]
    handle_key(key)
    input
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

  def update_pos(diff)
    new_pos = [@cursor_pos[0] + diff[0], @cursor_pos[1] + diff[1]]
    @cursor_pos = new_pos if @board.in_bounds?(new_pos)
  end

  def select_tile
    if @queue.include?(@cursor_pos)
      @queue.pop
    else
      @queue << @cursor_pos
    end
  end
end

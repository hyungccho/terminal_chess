require_relative './modules/cursorable.rb'
require 'colorize'

class Display
  include Cursorable

  def initialize(board)
    @board = board
    @cursor_pos = [0, 0]
    @queue = []
  end

  def render(color)
    system('clear')
    @board.grid.each_with_index do |row, y|
      holder = ""
      row.each_with_index do |el, x|
        if [y, x] == @cursor_pos
          holder += el.to_s.colorize(:background => :red)
        elsif x.even? && y.even?
          holder += el.to_s.colorize(:background => :yellow)
        elsif x.even? && y.odd?
          holder += el.to_s.colorize(:background => :green)
        elsif x.odd? && y.even?
          holder += el.to_s.colorize(:background => :green)
        elsif x.odd? && y.odd?
          holder += el.to_s.colorize(:background => :yellow)
        end
      end
      puts holder
    end
  end

  def take_input(color)
    render(color)
    until @queue.length == 2
      until get_input == "\r"
        render(color)
      end
    end
    [@queue.shift, @queue.shift]
  end

  private

    def highlight_cursor
      @board[@cursor_pos].to_s.colorize(:background => :red)
    end
end

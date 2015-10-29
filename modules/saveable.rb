require 'io/console'

module Saveable
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

  def get_input
    input = read_char
    if input == "\004"
      save_game
    end
  end

  def save_game
    puts "Enter filename:"
    file = gets.chomp

    File.open(file) do |f|
      f.write(self.to_yaml)
    end
  end
end

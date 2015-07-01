require_relative 'board.rb'
require 'byebug'
class MineSweeper


  def initialize(size = 9, num_bombs = 10)
    @save = false
    type = game_type
    if type == :N
      @board = Board.new(size, num_bombs)
    elsif type == :L
      @board = YAML.load(saved_file)
    end
  end

  def save_game
    filename = "saved_game"
    board.time_elapsed
    save_board = board.to_yaml
    File.open(filename, 'w') do |f|
      f.puts save_board
    end
  end

  def game_type
    puts "New Game: 'N' | Load Game: 'L'"
    input = gets.chomp.upcase.to_sym
  end

  def saved_file
    filename = "saved_game"
    File.read(filename).chomp
  end

  def play
    board.start_timer
    until win? || lose?
      system "clear"
      board.render_grid
      input = user_input
      if save?
        save_game
        break
      end
      board.mark_pos(input)
    end

    if win?
      puts "Yay! You won"
    elsif lose?
      puts "That's a bomb, you lose."
      board.show_bombs
    end
    board.render_grid
    puts board.time_elapsed
  end

  def win?
    board.win?
  end

  def lose?
    board.lose?
  end

  def save?
    self.save
  end

  def user_input
    pos = nil
    puts "Input Action: ('C' = Check, 'F' = Flag or Unflag, 'S' = Save & quit game)"
    action = gets.chomp.upcase.to_sym
    if action == :S
      self.save = true
      return
    end

    until pos && board.in_bounds?(pos)
      print "Input Coordinates (x,y): "
      pos = gets.chomp.strip.split(',').map {|coord| coord.to_i }
    end

    [pos, action]
  end

  protected
  attr_accessor :num_bombs, :board, :save
end

if __FILE__ == $PROGRAM_NAME
  game = MineSweeper.new(9,10)
  game.play
end

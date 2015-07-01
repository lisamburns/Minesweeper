require 'colorize'
class Tile
  attr_accessor :value, :status, :board, :neighbors, :position
  SURROUNDING_POSITIONS = [[0,1],
                          [0,-1],
                          [1,0],
                          [-1,0],
                          [1,1],
                          [-1,1],
                          [1,-1],
                          [-1,-1]]

  def initialize(value, board)
    @value = value
    @status = :unrevealed
    @board = board
    @neighbors = []
  end

  def make_bomb
    self.value = -1
  end

  def find_my_position
    board.grid.each_with_index do |row, counter|
      row.each_with_index do |_, index|
        self.position = [counter, index] if board[counter, index] == self
      end
    end
  end

  #TODO: Remove commented lines of code. Seriously.
  def to_s
    case status
    when :flagged
      'F'.colorize(:yellow)
    when :unrevealed
      '?'.colorize(:white)
    when :revealed
      if is_bomb?
        'B'.colorize(:red)
      else
        value.to_s.colorize(:blue)
      end
    end
  end

  def reveal
    self.status = :revealed if self.status != :flagged
  end

  def flag
    if self.status == :unrevealed
      self.status = :flagged
    elsif self.status == :flagged
      self.status = :unrevealed
    end
  end

  def is_bomb?
    value == -1
  end

  def flagged?
    status == :flagged
  end

  def revealed?
    status == :revealed
  end

  def gather_neighbors
    surroundings = SURROUNDING_POSITIONS.map do |shift|
      [shift.first + position.first, shift.last + position.last]
    end
    surroundings.select! { |pos| board.in_bounds?(pos) }
    surroundings.each { |pos| self.neighbors << board[*pos] }
    get_value
  end

  def get_value
    @value = @neighbors.count { |neighbor| neighbor.is_bomb? } unless self.is_bomb?
  end

end

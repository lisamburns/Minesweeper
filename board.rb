require_relative 'tile.rb'
class Board
attr_accessor :grid, :num_bombs

  def initialize(size, num_bombs)
    @total_time = 0
    @grid = Array.new(size) { Array.new(size) {Tile.new(0, self) } }
    @num_bombs = num_bombs
    set_tile_positions
    place_bombs
    grid.each { |row| row.each { |tile| tile.gather_neighbors } }
  end

  def set_tile_positions
    @grid.flatten.each {|tile| tile.find_my_position }
  end

  def start_timer
    @session_time = Time.now
  end

  def time_elapsed
    @total_time += Time.now - @session_time
  end

  def [](row,col)
    self.grid[row][col]
  end

  def []=(row,col,mark)
    self.grid[row][col] = mark
  end

  def win?
    non_bomb_tiles = grid.flatten.reject { |tile| tile.is_bomb? }
    non_bomb_tiles.all? {|tile| tile.revealed? }
  end

  def lose?
    bomb_tiles = grid.flatten.select {|tile| tile.is_bomb? }
    bomb_tiles.any? { |tile| tile.revealed? }
  end

  def show_bombs
    grid.flatten.each {|tile| tile.reveal if tile.is_bomb?}
  end

  def mark_pos(input)
    pos, action = input
    this_tile = self[*pos]
    if action == :C
      chain_reaction(this_tile) unless this_tile.flagged?
    elsif action == :F
      this_tile.flag
    end
  end

  def chain_reaction(tile)
    tile.reveal
    if tile.value == 0
      tile.neighbors.each {|neighbor| chain_reaction(neighbor) unless neighbor.revealed?}
    end
  end

  def render_grid
    print_rows = []
    puts "  " + (0..grid.size - 1).to_a.join(" ")
    grid.each_with_index do |row, index|
      puts "#{index} #{row.map {|tile| tile.to_s}.join(" ")}"
    end
  end

  def place_bombs
    bombs = bomb_positions
    bombs.each do |bomb|
       self[*bomb].make_bomb
    end
  end

  def in_bounds?(pos)
    min, max = 0, grid.size - 1
    pos.all? {|coord| coord.between?(min, max)}
  end

  def bomb_positions
    bombs = []
    until bombs.count == num_bombs
      row = rand(grid.size)
      col = rand(grid.size)
      bombs << [row,col] unless bombs.include?([row,col])
    end

    bombs
  end



end

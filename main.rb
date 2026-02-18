# Steps:
# Display Board
# Create any Piece (without characteristics)
# Put Piece on Board
# Test if Board displays
# Create a testing ground with some White/Black Pieces
#
# Add Movement Functions to Board & Piece (Knight, probably)
# Start Testing them
# Repeat with other Pieces until done (Knight, Bishop ... Pawn, probably)
## Add Illegal Move Checker
# Add Turn Order
# Initialize Game (Proper Starting Position)

class Game
  # Handle Turn Order
  # Check Illegal Moves
  # Check Win/Loss/Draw Conditions
end

class Board
  attr_reader :grid

  def initialize
    # grid[row][col] -> 8*8 -> 64 Squares
    @grid = Array.new(8) { Array.new(8, nil) }

    setup_pieces
  end

  # Starting Position:
  def setup_pieces
    # White pieces
    @grid[0][0] = Rook.new(:white)
    @grid[0][1] = Knight.new(:white)
    @grid[0][2] = Bishop.new(:white)
    @grid[0][3] = Queen.new(:white)
    @grid[0][4] = King.new(:white)
    @grid[0][5] = Bishop.new(:white)
    @grid[0][6] = Knight.new(:white)
    @grid[0][7] = Rook.new(:white)
    (0..7).each { |col| @grid[1][col] = Pawn.new(:white) }

    # Black pieces
    @grid[7][0] = Rook.new(:black)
    @grid[7][1] = Knight.new(:black)
    @grid[7][2] = Bishop.new(:black)
    @grid[7][3] = Queen.new(:black)
    @grid[7][4] = King.new(:black)
    @grid[7][5] = Bishop.new(:black)
    @grid[7][6] = Knight.new(:black)
    @grid[7][7] = Rook.new(:black)
    (0..7).each { |col| @grid[6][col] = Pawn.new(:black) }
  end

  # NOTE: This Display doesn't actually print the 'board'. It creates a board-like structure, using data from the @grid
  def display
    puts # Empty Line for Clarity

    # Printing 1-8 on the sides
    7.downto(0) do |row|
      print "#{row + 1}  "

      # The 'Meat' of the Function, filling in all the squares or our Row*Col based on @grid data
      0.upto(7) do |col|
        if @grid[row][col].nil?
          print '. '
        else
          print "#{@grid[row][col]} "
        end
      end

      puts
    end

    # Printing a-h at the bottom
    puts '   a b c d e f g h'
    puts # Empty Line for Clarity
  end
end

class Pawn
  attr_accessor :color, :moved

  def initialize(color)
    @color = color
    @moved = false
  end

  def to_s
    @color == :white ? '♟' : '♙'
  end

  # attr_accessor :moved
  #
  # Base Movement: Can't move over the same tiles as other pieces
  #
  # Can move forward one Tile:
  #   [0,3] -> [0,4]
  # First Move can move two Tiles:
  #   [0,1] -> [0,3]
  #   Mark as 'has_first_moved'
  # Taking is forward diagonal one Tile:
  #   [0,3] -> [1,4]
  #
  # En Passant
  #   Can take diagonally on the tile *behind* a Pawn that has 'has_first_moved', removing that Pawn
  #   White:
  #   [0,1] -> [0,3]
  #   Black:
  #   [1,3] -> [0,2]
  #   Delete White Pawn at
  # Promotion, something like:
  #   board.delete(this_pawn)
  #   board.initialize(Queen)
end

class Knight
  attr_accessor :color, :moved

  def initialize(color)
    @color = color
    @moved = false
  end

  def to_s
    @color == :white ? '♞' : '♘'
  end
  # 'Jumping' Movement: Can move over other pieces
  # 8 Options, no further requirements
end

class Bishop
  attr_accessor :color, :moved

  def initialize(color)
    @color = color
    @moved = false
  end

  def to_s
    @color == :white ? '♝' : '♗'
  end
  # Base Movement: Can't move over the same tiles as other pieces
  # Diagonal only:
  #   [0,0] -> [1,1] -> [2,2]
end

class Rook
  attr_accessor :color, :moved

  def initialize(color)
    @color = color
    @moved = false
  end

  def to_s
    @color == :white ? '♜' : '♖'
  end
  # attr_accessor :moved
  #
  # Base Movement: Can't move over the same tiles as other pieces
  # Straight only:
  # [0,0] -> [0,1], [0,2]
end

class Queen
  attr_accessor :color, :moved

  def initialize(color)
    @color = color
    @moved = false
  end

  def to_s
    @color == :white ? '♛' : '♕'
  end
  # Base Movement: Can't move over the same tiles as other pieces
  # Straight and Diagonal. I.E. Bishop + Rook
end

class King
  attr_accessor :color, :moved

  def initialize(color)
    @color = color
    @moved = false
  end

  def to_s
    @color == :white ? '♚' : '♔'
  end

  # attr_accessor :moved
  #
  # Base Movement: Can't move over the same tiles as other pieces
  # Can move one Tile in any Direction
  #
  # Castling
end

board = Board.new
board.display

# Steps:
#
# Display Board
# Create any Piece (without characteristics)
# Put Piece on Board
# Test if Board displays
#
# Create a testing ground with some White/Black Pieces
# Add Movement Functions to Board & Piece (Knight, probably)
# Start Testing them
# Repeat with other Pieces until done (Knight, Bishop ... Pawn, probably)
#
# Add Illegal Move Checker
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
    # grid[row][col]
    @grid = Array.new(8) { Array.new(8, nil) }
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
  # 'Jumping' Movement: Can move over other pieces
  # 8 Options, no further requirements
end

class Bishop
  # Base Movement: Can't move over the same tiles as other pieces
  # Diagonal only:
  #   [0,0] -> [1,1] -> [2,2]
end

class Rook
  # attr_accessor :moved
  #
  # Base Movement: Can't move over the same tiles as other pieces
  # Straight only:
  # [0,0] -> [0,1], [0,2]
end

class Queen
  # Base Movement: Can't move over the same tiles as other pieces
  # Straight and Diagonal. I.E. Bishop + Rook
end

class King
  # attr_accessor :moved
  #
  # Base Movement: Can't move over the same tiles as other pieces
  # Can move one Tile in any Direction
  #
  # Castling
end

board = Board.new
board.display

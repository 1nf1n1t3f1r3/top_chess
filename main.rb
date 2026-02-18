# Steps:
# Board
# Display Board
# Create any Piece
# Put Piece on Board
# Test if Board displays
#
# Create a testing ground with some White/Black Pieces
# Add Movement Functions to Board & Piece
# Test them
# Repeat with other Pieces until done (Knight, Bishop ... Pawn, probably)
#
# Add Illegal Move Checker
# Add Turn Order
# Initialize Game (Proper Starting Position)

class Main
  # Handle Turn Order
  # Check Illegal Moves
  # Check Win/Loss/Draw Conditions
end

class Board
  # Store [0,0] to [7,7]
  # (Helper Function to convert into A1-H8)
  # Store piece Objects on it
  # Handle final/'actual' step of all Pieces' movement onto the actual Board
end

class Pawn
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

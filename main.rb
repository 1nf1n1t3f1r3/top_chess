# Steps:
# Display Board
# Create any Piece (without characteristics)
# Put Piece on Board
# Test if Board displays
# Create a testing ground with some White/Black Pieces
#
# Add Turn Order
# Add Movement Functions to Board & Piece (Knight, probably)
# Start Testing them
# Repeat with other Pieces until done (Knight, Bishop ... Pawn, probably)
## Add Illegal Move Checker
# #
# Make sure to check when two pieces can move to the same position

class Game
  def initialize
    @board = Board.new
    @players = [Player.new(:white, :human), Player.new(:black, :ai)]
    @current_player_index = 0
  end

  def play_turn
    player = @players[@current_player_index]
    @board.display
    from, to = player.get_move(@board)

    piece = @board.grid[from[0]][from[1]]
    if piece.nil? || piece.color != player.color
      puts 'Invalid selection!'
      return
    end

    moves = piece.possible_moves(@board, from[0], from[1])
    unless moves.include?(to)
      puts 'Illegal move!'
      return
    end

    @board.move_piece(from, to)
    @current_player_index = 1 - @current_player_index
  end

  # Handle Turn Order
  # Check Illegal Moves
  # Check Win/Loss/Draw Conditions
end

class Player
  attr_reader :color

  PIECES = %w[N B R Q K]

  def initialize(color, type = :human)
    @color = color
    @type = type # :human or :ai
  end

  def get_move(board)
    return ai_move(board) unless @type == :human

    loop do
      puts "#{@color.capitalize}'s move (e.g. Nb1-c3, e2-e4, 0-0, 0-0-0):"
      input = gets.chomp.strip

      # Handle castling
      if input == '0-0'
        return [:castle_kingside]
      elsif input == '0-0-0'
        return [:castle_queenside]
      end

      # Parse standard move: <Piece?><from>-<to>, e.g., Nb1-c3 or e2-e4
      match = input.match(/^([NBRQK]?)([a-h][1-8])-([a-h][1-8])$/i)
      unless match
        puts 'Invalid notation!'
        next
      end

      piece_prefix = match[1] # Theoretically optional, but for style. Empty for pawn
      from_square = match[2]
      to_square = match[3]

      from = Board.algebraic_to_coords(from_square)
      to   = Board.algebraic_to_coords(to_square)

      # Validate Piece Prefix matches Piece at Selected Square
      piece = board.grid[from[0]][from[1]]
      if piece.nil? || piece_prefix.upcase != piece.to_unicode || piece.color != @color
        puts "No/Invalid Piece #{piece} selected at #{from_square}!"
        next
      end

      return [from, to]
    end
  end

  # For extra credit, simple AI could just pick a random piece and legal move
  def ai_move(board)
    pieces = []
    board.grid.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        next if piece.nil? || piece.color != @color

        moves = piece.possible_moves(board, r, c)
        pieces << [[r, c], moves] unless moves.empty?
      end
    end

    return nil if pieces.empty?

    from, moves = pieces.sample
    to = moves.sample
    [from, to]
  end
end

class Board
  attr_reader :grid

  FILES = ('a'..'h').to_a
  RANKS = (1..8).to_a

  def initialize
    # grid[row][col] -> 8*8 -> 64 Squares
    @grid = Array.new(8) { Array.new(8, nil) }

    setup_board
  end

  # Starting Position:
  def setup_board
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

  def move_piece(from, to)
    piece = @grid[from[0]][from[1]]
    if piece.nil?
      puts 'No piece at the starting position!'
      return
    end

    # Move piece to destination
    @grid[to[0]][to[1]] = piece

    # Clear the starting square
    @grid[from[0]][from[1]] = nil

    # Optional: mark that the piece has moved (for pawns, rooks, king)
    piece.moved = true if piece.respond_to?(:moved)

    display
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

  def self.algebraic_to_coords(square)
    file = square[0].downcase
    rank = square[1].to_i
    col = FILES.index(file)
    row = rank - 1
    [row, col]
  end
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

  def to_unicode
    'N'
  end

  # 'Jumping' Movement: Can move over other pieces
  def possible_moves(board, row, col)
    moves = []

    # All 8 possible "L" moves
    deltas = [
      [2, 1], [1, 2], [-1, 2], [-2, 1],
      [-2, -1], [-1, -2], [1, -2], [2, -1]
    ]

    # Deltas + Start Pos
    deltas.each do |dr, dc|
      r = row + dr
      c = col + dc

      # Only include moves inside the board
      next unless r.between?(0, 7) && c.between?(0, 7)

      # Check if empty square or enemy piece
      target = board.grid[r][c]
      moves << [r, c] if target.nil? || target.color != color
    end

    moves
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

  def to_unicode
    ''
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

class Bishop
  attr_accessor :color, :moved

  def initialize(color)
    @color = color
    @moved = false
  end

  def to_s
    @color == :white ? '♝' : '♗'
  end

  def to_unicode
    'B'
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

  def to_unicode
    'R'
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

  def to_unicode
    'Q'
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

  def to_unicode
    'K'
  end

  # Base Movement: Can't move over the same tiles as other pieces
  # Can move one Tile in any Direction
  #
  # Castling
end

# board = Board.new
# board.display
# knight = board.grid[0][1]
# moves = knight.possible_moves(board, 0, 1)
# puts "Knight at b1 can move to: #{moves.map { |r, c| [r, c] }}"

game = Game.new
game.play_turn

# Steps:
# Stop the game from breaking when typing 0-0
# Disallow Castling when Checked
# Add Victory Condition Checker
#
# Bonus?:
# Add Saving
# Add AI?
#
# QOL Notation:
# Short Notation
# Allow '*' or 'x' for '-' IFF there's Piece to be captured
# e8Q for Promotion
# 0-0 and 0-0-0  for Castling

class Game
  def initialize
    @board = Board.new
    @players = [Player.new(:white, :human), Player.new(:black, :human)]
    @current_player_index = 0
  end

  def play_turn
    player = @players[@current_player_index]
    @board.display
    from, to = player.get_move(@board)

    # Get the Piece
    piece = @board.grid[from[0]][from[1]]
    if piece.nil? || piece.color != player.color
      puts 'Invalid Selection!'
      return
    end

    # Get the Move
    moves = piece.possible_moves(@board, from[0], from[1])
    unless moves.include?(to)
      puts 'Illegal Move!'
      return
    end

    if @board.move_causes_check?(from, to, player.color)
      puts 'Move leaves King in Check!'
      return
    end

    # Move
    @board.move_piece(from, to)

    # Swap Turn
    @current_player_index = 1 - @current_player_index
  end

  # Main game loop
  def play_match
    loop do
      play_turn
      break if victory_condition?
    end

    @board.display
    puts 'Game over!'
  end

  def victory_condition?
    false # TODO: Implement checkmate/draw
  end
end

class Player
  attr_reader :color

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
  attr_reader :grid, :en_passant_target

  FILES = ('a'..'h').to_a
  RANKS = (1..8).to_a

  def initialize
    # grid[row][col] -> 8*8 -> 64 Squares
    @grid = Array.new(8) { Array.new(8, nil) }
    @en_passant_target = nil

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

  # Move the Piece on the Board
  def move_piece(from, to)
    piece = @grid[from[0]][from[1]] # Grid A-H/1-8
    if piece.nil?
      puts 'No piece at the starting position!'
      return
    end

    # En passant capture
    if piece.is_a?(Pawn) && to == @en_passant_target
      direction = piece.color == :white ? -1 : 1
      captured_row = to[0] + direction
      @grid[captured_row][to[1]] = nil
    end

    # Move piece to destination & clear starting square
    @grid[to[0]][to[1]] = piece
    @grid[from[0]][from[1]] = nil

    # Reset en passant target
    @en_passant_target = nil

    # Set new en passant if double pawn move
    if piece.is_a?(Pawn) && (from[0] - to[0]).abs == 2
      middle_row = (from[0] + to[0]) / 2
      @en_passant_target = [middle_row, from[1]]
    end

    # Special Cases: Promotion & Castling. Castling moves the Rook 'separately'
    handle_promotion(to)
    handle_castling_rook(from, to) if piece.is_a?(King) && (from[1] - to[1]).abs == 2

    # Mark that the piece has moved (for pawns, rooks, king)
    piece.moved = true if piece.respond_to?(:moved)
  end

  # Check if a Move causes Check. Do the Move in a 'Temporary' Vacuum, then revert it if in_check = true
  def move_causes_check?(from, to, color)
    original_from = @grid[from[0]][from[1]]
    original_to   = @grid[to[0]][to[1]]

    # Make temporary move
    @grid[to[0]][to[1]] = original_from
    @grid[from[0]][from[1]] = nil

    in_check = in_check?(color)

    # Undo move
    @grid[from[0]][from[1]] = original_from
    @grid[to[0]][to[1]] = original_to

    in_check
  end

  # Find the King, find the Enemy, find its Pieces, find all possible Movements, return true if those include our king_pos
  def in_check?(color)
    king_pos = find_king(color)

    enemy_color = color == :white ? :black : :white

    @grid.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        next if piece.nil? || piece.color != enemy_color

        moves = piece.possible_moves(self, r, c)
        return true if moves.include?(king_pos)
      end
    end

    false
  end

  # Like In Check, but for any Square (Though any Square is only 4 possible Squares during Castling)
  def square_attacked?(row, col, color)
    enemy_color = color == :white ? :black : :white

    @grid.each_with_index do |r_row, r|
      r_row.each_with_index do |piece, c|
        next if piece.nil? || piece.color != enemy_color

        moves = piece.possible_moves(self, r, c)
        return true if moves.include?([row, col])
      end
    end

    false
  end

  # Helper to Find the King
  def find_king(color)
    @grid.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        return [r, c] if piece.is_a?(King) && piece.color == color
      end
    end
  end

  # Handles moving the Rook, kind of as a bonus to the King movement
  def handle_castling_rook(from, to)
    row = from[0]

    if to[1] == 6 # King sided
      rook = @grid[row][7]
      @grid[row][5] = rook
      @grid[row][7] = nil
      rook.moved = true
    elsif to[1] == 2 # Queen side
      rook = @grid[row][0]
      @grid[row][3] = rook
      @grid[row][0] = nil
      rook.moved = true
    end
  end

  # Promotion Caller when reaching the final Square
  def handle_promotion(position)
    row, col = position
    piece = @grid[row][col]

    return unless piece.is_a?(Pawn)

    # White promotes at row 7, black at row 0
    if (piece.color == :white && row == 7) ||
       (piece.color == :black && row == 0)

      promote_pawn(row, col, piece.color)
    end
  end

  # Promotion handler based on Input (Q, R, B, N)
  def promote_pawn(row, col, color)
    puts 'Promote pawn to (Q, R, B, N):'
    choice = gets.chomp.upcase

    new_piece =
      case choice
      when 'Q' then Queen.new(color)
      when 'R' then Rook.new(color)
      when 'B' then Bishop.new(color)
      when 'N' then Knight.new(color)
      else
        puts 'Invalid choice. Defaulting to Queen.'
        Queen.new(color)
      end

    @grid[row][col] = new_piece
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

  # Notation Helper
  def self.algebraic_to_coords(square)
    file = square[0].downcase
    rank = square[1].to_i
    col = FILES.index(file)
    row = rank - 1
    [row, col]
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

  def possible_moves(board, row, col)
    moves = []
    direction = color == :white ? 1 : -1

    # 1 Forward: Take Position + Intended destination and add it if it's available
    one_step = row + direction
    if one_step.between?(0, 7) && board.grid[one_step][col].nil?
      moves << [one_step, col]

      # ---- 2. Forward Two (if not moved yet) ----
      two_step = row + (2 * direction)
      moves << [two_step, col] if !moved && board.grid[two_step][col].nil?
    end

    # 3 Diagonal Captures. First Check one Left
    [-1, 1].each do |dc|
      r = row + direction
      c = col + dc
      next unless r.between?(0, 7) && c.between?(0, 7)

      target = board.grid[r][c]

      # Normal capture
      moves << [r, c] if !target.nil? && target.color != color

      # En passant
      moves << [r, c] if board.en_passant_target == [r, c]
    end
    moves
  end

  # TODO: Perhaps?: Allow Promotion by e7-e8Q
end

class Knight
  attr_accessor :color, :moved

  def initialize(color)
    @color = color
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

class Bishop
  attr_accessor :color, :moved

  def initialize(color)
    @color = color
  end

  def to_s
    @color == :white ? '♝' : '♗'
  end

  def to_unicode
    'B'
  end

  def possible_moves(board, row, col)
    moves = []

    # All Diagonals it can move towards
    directions = [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ]

    # Diagonals + Start Pos
    directions.each do |dr, dc|
      r = row + dr
      c = col + dc

      # Loop as long as we find valid squares, or squares occupied by the enemy
      while r.between?(0, 7) && c.between?(0, 7)
        target = board.grid[r][c]

        if target.nil?
          moves << [r, c]
        else
          # Enemy piece → capture and stop
          moves << [r, c] if target.color != color
          break
        end

        r += dr
        c += dc
      end
    end

    moves
  end
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

  def possible_moves(board, row, col)
    moves = []

    # All Straights it can move towards
    directions = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0]
    ]

    # Straights + Start Pos
    directions.each do |dr, dc|
      r = row + dr
      c = col + dc

      # Loop as long as we find valid squares, or squares occupied by the enemy
      while r.between?(0, 7) && c.between?(0, 7)
        target = board.grid[r][c]

        if target.nil?
          moves << [r, c]
        else
          # Enemy piece → capture and stop
          moves << [r, c] if target.color != color
          break
        end

        r += dr
        c += dc
      end
    end

    moves
  end
end

class Queen
  attr_accessor :color, :moved

  def initialize(color)
    @color = color
  end

  def to_s
    @color == :white ? '♛' : '♕'
  end

  def to_unicode
    'Q'
  end

  def possible_moves(board, row, col)
    moves = []

    # All Straights & Diagonals it can move towards
    directions = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0],

      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ]

    # Straights & Diagonals + Start Pos
    directions.each do |dr, dc|
      r = row + dr
      c = col + dc

      # Loop as long as we find valid squares, or squares occupied by the enemy
      while r.between?(0, 7) && c.between?(0, 7)
        target = board.grid[r][c]

        if target.nil?
          moves << [r, c]
        else
          # Enemy piece → capture and stop
          moves << [r, c] if target.color != color
          break
        end

        r += dr
        c += dc
      end
    end

    moves
  end
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

  def possible_moves(board, row, col)
    moves = []

    # All Straights & Diagonals it can move towards
    directions = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0],

      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ]

    # Straights & Diagonals + Start Pos
    directions.each do |dr, dc|
      r = row + dr
      c = col + dc

      next unless r.between?(0, 7) && c.between?(0, 7)

      target = board.grid[r][c]

      moves << [r, c] if target.nil? || target.color != color
    end

    return moves if moved # (Can't Castle because Moved)

    # Castling: King/Short and Queen/Long
    moves << [row, col + 2] if can_castle_kingside?(board, row, col)
    moves << [row, col - 2] if can_castle_queenside?(board, row, col)

    moves
  end

  # Check if Square is occupied by a Rook.
  # Check if Rook has .moved.
  # Check if King has .moved
  # Check if the King's Itinerary Squares are nil and not under Attack
  # Check if the King's currently Check
  def can_castle_kingside?(board, row, col)
    rook = board.grid[row][7]
    return false unless rook.is_a?(Rook)
    return false if rook.moved
    return false if moved
    return false unless board.grid[row][5].nil? && board.grid[row][6].nil?
    return false if board.in_check?(color)
    return false if board.square_attacked?(row, col + 1, color)

    true
  end

  def can_castle_queenside?(board, row, col)
    rook = board.grid[row][0]
    return false unless rook.is_a?(Rook)
    return false if rook.moved
    return false if moved
    return false unless board.grid[row][1].nil? && board.grid[row][2].nil? && board.grid[row][3].nil?
    return false if board.in_check?(color)
    return false if board.square_attacked?(row, col - 1, color)

    true
  end
end

game = Game.new
game.play_match

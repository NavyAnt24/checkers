require './piece.rb'
require 'colorize'

class MoveError < StandardError
end

class Board
  attr_reader :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    generate_pieces(:red)
    generate_pieces(:black)
  end

  def generate_pieces(color)
    rows = color == :black ? [0,1,2] : [5,6,7]
    rows.each do |row|
      8.times do |column|
        if row % 2 == 0
          if column % 2 == 0
            @grid[row][column] = Piece.new(color)
          end
        else
          if column % 2 != 0
            @grid[row][column] = Piece.new(color)
          end
        end
      end
    end
  end

  def print_board
    puts
    @grid.length.times do |row|
      print " #{row} " # can add 1 if you want columns to be 1 - 8
      @grid.length.times do |column|
        if (row + column) % 2 == 0
          background_color = :white
        else
          background_color = :yellow
        end

        piece = get_piece_at_position(row, column)
        if piece.nil?
          print "   ".colorize(:background => background_color)
        else
          checkers_symbol = piece.king ? "\u25EF".encode("UTF-8") : "\u2B24".encode("UTF-8")
          print " #{checkers_symbol} ".colorize(:color => piece.color, :background => background_color)
        end
      end
      puts
    end

  print "   "
  8.times do |column_num|
    print " #{column_num} " # can add 1 if you want columns to be 1 - 8
  end
  puts

  end

  def get_piece_at_position(row, column)
    @grid[row][column]
  end

  def jump_available?(current_color)
    8.times do |row|
      8.times do |column|
        if !@grid[row][column].nil?
          piece = get_piece_at_position(row, column)
          if piece.color == current_color
            jump_moves = piece_jump_moves([row, column])
            if jump_possible?([row, column], jump_moves, current_color)
              return true
            end
          end
        end
      end
    end
    false
  end

  def jump_possible?(from_position, jump_moves, current_color)
    jump_moves.each do |jump_vector|
      to_position = from_position.zip(jump_vector).map { |x,y| x+y }
      pos_between = position_in_between(from_position, to_position)
      piece_between = get_piece_at_position(pos_between[0], pos_between[1])
      if get_piece_at_position(to_position[0], to_position[1]).nil?
        if !piece_between.nil? && piece_between.color != current_color
          return true
        end
      end
    end
    false
  end

  def piece_jump_moves(from_position)
    jump_moves = []
    piece = get_piece_at_position(from_position[0], from_position[1])
    pos_moves = possible_moves(from_position, piece)
    pos_moves.each do |move|
      if move[0].abs == 2 && move[1].abs == 2
        jump_moves << move
      end
    end
    return pos_moves
    return jump_moves
  end

  def perform_slide(from_position, to_position)
      piece = get_piece_at_position(from_position[0], from_position[1])
      @grid[from_position[0]][from_position[1]] = nil
      @grid[to_position[0]][to_position[1]] = piece
  end

  def perform_jump(from_position, to_position)
      piece = get_piece_at_position(from_position[0], from_position[1])
      @grid[from_position[0]][from_position[1]] = nil
      @grid[to_position[0]][to_position[1]] = piece
      between_position_row, between_position_column = position_in_between(from_position, to_position)
      @grid[between_position_row][between_position_column] = nil
  end

  def position_in_between(from_position, to_position)
    row_difference = to_position[0] - from_position[0]
    column_difference = to_position[1] - from_position[1]
    between_position_row = from_position[0] + row_difference / 2
    between_position_column = from_position[1] + column_difference / 2
    return between_position_row, between_position_column
  end

  def move(from_position, to_position)
    p valid_move?(from_position, to_position)
    if valid_move?(from_position, to_position)
      if jump_move?(from_position, to_position)
        perform_jump(from_position, to_position)
      else
        perform_slide(from_position, to_position)
      end
      king_me(to_position)
    end
  end

  def king_me(to_position)
    piece = get_piece_at_position(to_position[0], to_position[1])
    if piece.color == :red
      if to_position[0] == 0
        piece.king = true
      end
    else #piece.color = :black
      if to_position[0] == 7
        piece.king = true
      end
    end
  end

  def my_piece?(from_position, current_color)
    if get_piece_at_position(from_position[0], from_position[1]).color != current_color
      raise MoveError.new "That piece is not yours!"
    end
  end

  def piece_there?(from_position)
    if get_piece_at_position(from_position[0], from_position[1]).nil?
      return false
    end
    return true
  end

  def valid_move?(from_position, to_position)
    piece = get_piece_at_position(from_position[0], from_position[1])
    possible_moves = possible_moves(from_position, piece)

    if !get_piece_at_position(to_position[0], to_position[1]).nil?
      raise MoveError.new "That position is occupied."
      # return false
    else
      if jump_move?(from_position, to_position)
        pos_between = position_in_between(from_position, to_position)
        if get_piece_at_position(pos_between[0], pos_between[1]).nil?
          raise MoveError.new "You cannot jump if there is no piece in between."
          # return false
        end
      else
        if !possible_moves(from_position, piece).include?(to_position)
          raise MoveError.new "That is not a valid move."
          # return false
        end
      end
    end
    return true
  end

  def jump_move?(from_position, to_position)
    row_difference = to_position[0] - from_position[0]
    column_difference = to_position[1] - from_position[1]
    if row_difference.abs == 2 || column_difference == 2
      return true
    end
    false
  end

  def vectors(piece)
    non_king_red_vectors = [[-1,-1], [-1,1], [-2,-2], [-2,2]]
    non_king_black_vectors = [[1,-1], [1,1], [2,-2], [2,2]]

    if piece.king
      vectors = non_king_red_vectors + non_king_black_vectors
    else
      if piece.color == :red
        vectors = non_king_red_vectors
      else
        vectors = non_king_black_vectors
      end
    end
    vectors
  end

  def possible_moves(from_position, piece)
    vectors = vectors(piece)
    possible_moves = []
    vectors.each do |vector|
      possible_position = from_position.zip(vector).map { |x,y| x+y }
      if on_board?(possible_position)
        possible_moves << from_position.zip(vector).map { |x,y| x+y }
      end
    end
    possible_moves
  end

  def on_board?(position)
    if position[0] < 0 || position [0] > 7 || position[1] < 0 || position[1] > 7
      return false
    end
    true
  end

end
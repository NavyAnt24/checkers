require './piece.rb'
require 'colorize'

class MoveError < StandardError
end

class Board

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
          checkers_symbol = piece.king ? "\u25EF".encode(UTF-8) : "\u2B24".encode("UTF-8")
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

  def perform_slide(from_position, to_position)
#    if valid_move?(from_position, to_position)
      piece = get_piece_at_position(from_position[0], from_position[1])
      @grid[from_position[0]][from_position[1]] = nil
      @grid[to_position[0]][to_position[1]] = piece
#    end
  end

  def perform_jump(from_position, to_position)
    # if valid_move?(from_position, to_position)
      piece = get_piece_at_position(from_position[0], from_position[1])
      @grid[from_position[0]][from_position[1]] = nil
      @grid[to_position[0]][to_position[1]] = piece
      between_position_row, between_position_column = position_in_between(from_position, to_position)
      @grid[between_position_row][between_position_column] = nil
    # end
  end

  def position_in_between(from_position, to_position)
    row_difference = to_position[0] - from_position[0]
    column_difference = to_position[1] - from_position[1]
    between_position_row = from_position[0] + row_difference / 2
    between_position_column = from_position[1] + column_difference / 2
    return between_position_row, between_position_column
  end

  def valid_move?(from_position, to_position)
    piece = get_piece_at_position(from_position[0], from_position[1])
    possible_moves = possible_moves(from_position, piece)

    if !get_piece_at_position[to_position[0], to_position[1]).nil?
      raise MoveError "That position is occupied."
      # return false
    else
      if jump_move?(from_position, to_position)
        if get_piece_at_position(position_in_between(from_position, to_position)).nil?
          raise MoveError "You cannot jump if there is no piece in between."
          # return false
      else
        if !possible_moves(from_position).include?(to_position)
        # return false
      end
    end


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
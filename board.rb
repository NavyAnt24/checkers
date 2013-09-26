require './piece.rb'
require 'colorize'

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

    @grid.length.times do |row|
      print " #{row+1} "
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
  end

  ### FIX COLUMN NUMBERS
  8.times do |column_num|
    print " #{column_num+1} "
  end

  end

  def get_piece_at_position(row, column)
    @grid[row][column]
  end

  def perform_slide(from_position, to_position)
    if valid_move?Í(from_position, to_position)
      piece = get_piece_at_position(from_position[0], from_position[1])
      @grid[from_position[0]][from_position[1]] = nil
      @grid[to_position[0]][to_position[1]] = piece
    end
  end

  def perform_jump

  end



end
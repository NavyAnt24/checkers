require './board.rb'

class MoveError < StandardError
end

class Game

  def initialize
    @board = Board.new
  end

  def play
    puts "Welcome to Checkers! Will this be a 0, 1, or 2 'Human' Player game? (Enter a number)"
    num_players = gets.chomp.to_i
    if num_players == 2
      two_player
    end
  end

  def two_player
    current_color = :red
    until won?
      begin
        @board.print_board
        puts "It is #{current_color}'s turn."
        puts "Where would you like to move from?"
        move_from = gets.chomp.split("").map(&:to_i)
        if !@board.on_board?(move_from)
          raise MoveError.new "That is not a position on the board!"
        else
          if @board.piece_there?(move_from)
            @board.my_piece?(move_from, current_color)
          else
            raise MoveError.new "There is no piece there!"
          end
        end

        puts "Where would you like to move to?"
        move_to = gets.chomp.split("").map(&:to_i)
        if !@board.on_board?(move_to)
          raise MoveError.new "That is not a position on the board!"
        end

        if @board.jump_available?(current_color)
          p "Jump available!"
          available_jumps = @board.piece_jump_moves(move_from)
          if !@board.jump_move?(move_from, move_to) || !@board.jump_possible?(move_from, available_jumps, current_color)
            raise MoveError.new "There is a jump move available and you are not jumping!"
          end
        end

        @board.move(move_from, move_to)
#        system("clear")
      rescue MoveError => e
        puts "Error: #{e.message}".red.blink
        retry
      end
      current_color = current_color == :red ? :black : :red
    end

    puts "Game over! The winner is #{winner}".red.blink
    @board.print_board
  end

  def remaining_piece_colors
    pieces_on_board = []
    8.times do |row|
      8.times do |column|
        if !@board.grid[row][column].nil?
          pieces_on_board << @board.get_piece_at_position(row, column)
        end
      end
    end

    piece_colors = pieces_on_board.map do |piece|
      piece.color
    end
    piece_colors
  end

  def won?
    if remaining_piece_colors.include?(:red) && remaining_piece_colors.include?(:black)
      return false
    end
    true
  end

  def winner
    remaining_colors = remaining_piece_colors
    if !remaining_colors.include?(:red)
      return :black
    else
      return :red
    end
  end

end
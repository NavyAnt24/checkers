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

        @board.move(move_from, move_to)
        system("clear")
      rescue MoveError => e
        puts "Error: #{e.message}".red.blink
        retry
      end
      current_color = current_color == :red ? :black : :red
    end
  end

  def won?
    pieces_on_board =
  end

end
require './board.rb'

class MoveError < StandardError
end

class Game

  def initialize
    @board = Board.new
  end

  def play
    current_color = :red
    puts "Welcome to Checkers! Will this be a 0, 1, or 2 'Human' Player game? (Enter a number)"
    num_players = gets.chomp.to_i
    until won?

      if num_players == 2
        begin
          @board.print_board
          puts "It is #{current_color}'s turn."
          puts "Where would you like to move from?"
          move_from = gets.chomp.split("").map(&:to_i)
          @board.my_piece?(move_from, current_color)

          puts "Where would you like to move to?"
          move_to = gets.chomp.split("").map(&:to_i)

          @board.move(move_from, move_to)
          system("clear")
        rescue MoveError => e
          puts "Error: #{e.message}".red.blink
          retry
        end
        current_color = current_color == :red ? :black : :red
      end

    end

  end

  def won?
    false
  end

end
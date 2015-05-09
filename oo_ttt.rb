# nouns: board, player, computer, square
# behavior: player choice, choices in a line?, draw board,

class Board
  attr_accessor :squares

  def initialize
    @squares = {}
  end

  def draw
    system 'clear'

    puts "-------------------"
    3.times.each do |i|
      puts "|  #{squares[1 + i * 3]}  |  #{squares[2 + i * 3]}  |  #{squares[3 + i * 3]}  |"
      puts("------+-----+------") if i < 2
    end
    puts "-------------------"
  end

  def new!
    9.times {|p| self.squares[p + 1] = ' ' }
  end

  def unpicked
    squares.select {|_,v| v == ' ' }.keys
  end
end

class Player
  attr_reader :name
  attr_accessor :choices

  def initialize(name= 'player')
    @choices = []
    @name = name
  end

  def win?
    Game::WINNING_LINES.any? do |line|
      line.all? {|i| choices.include?(i)}
    end
  end

  def display_winning_message
    puts "#{name} won!"
  end

  def choose(board)
    choice = get_choice(board)
    self.choices << choice
    board.squares[choice] = self.class::MARK
  end

end

class Human < Player
  MARK = 'X'

  def get_choice(board)
    begin
      puts "Choose a square:#{board.unpicked}"
      answer = gets.chomp.to_i
    end until board.unpicked.include?(answer)

    answer
  end
end

class Computer < Player
  MARK = 'O'

  def get_choice(board)
    smarter_choices = []
    two_computer_mark = []
    two_player_mark = []
    one_computer_mark = []
    one_player_mark = []

    Game::WINNING_LINES.each do |line|
      unpicked_squares = board.squares.select{|k,v| line.include?(k) && v == ' '}.keys
      case board.squares.values_at(*line).sort
      when ([Computer::MARK] * 2 + [' ']).sort
        two_computer_mark += unpicked_squares
      when ([Human::MARK] * 2 + [' ']).sort
        two_player_mark += unpicked_squares
      when ([' '] * 2 + [Computer::MARK]).sort
        one_computer_mark += unpicked_squares
      when ([' '] * 2 + [Human::MARK]).sort
        one_player_mark += unpicked_squares
      end
    end

    [ two_computer_mark,
      two_player_mark,
      one_computer_mark,
      one_player_mark,
      board.unpicked  ].each do |choices|
        if choices.any?
          smarter_choices = choices
          break
        end
      end

    smarter_choices.sample
  end
end

class Game
  attr_reader :player, :computer, :board
  WINNING_LINES = [ [1,2,3],
                    [4,5,6],
                    [7,8,9],
                    [1,4,7],
                    [2,5,8],
                    [3,6,9],
                    [1,5,9],
                    [3,5,7]  ]

  def initialize
    @player = Human.new(get_user_name)
    @computer = Computer.new('Computer')
    @board = Board.new
  end

  def get_user_name
    puts "What's your name?"
    answer = gets.chomp.downcase.capitalize
  end

  def players_take_turn_choose(board)
    while board.unpicked.any?
      board.draw

      player.choose(board)
      board.draw
      if player.win?
        player.display_winning_message
        break
      end

      computer.choose(board)
      board.draw
      if computer.win?
        computer.display_winning_message
        break
      end
    end

    puts "It's a tie!" unless computer.win? || player.win?
  end

  def run
    loop do
      board.new!
      reset_players_choice
      players_take_turn_choose(board)
      break unless once_again?
    end
  end

  def once_again?
    begin
      puts "#{player.name}, once again?(y/n)"
      answer = gets.chomp
    end until ['y', 'n'].include?(answer)

    answer == 'y'
  end

  def reset_players_choice
    player.choices.clear
    computer.choices.clear
  end
end

system "clear"
puts "Welcome to Play Tic Tac Toe!"
Game.new.run
puts "Goodbye!"

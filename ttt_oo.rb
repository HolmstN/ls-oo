require 'pry'

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +   # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +   # columns
                  [[1, 5, 9], [3, 5, 7]]                # diagonals

  def initialize
    @squares = {}
    reset
  end

  def draw
    puts "     |     |   "
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |   "
    puts "-----|-----|-----"
    puts "     |     |   "
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |   "
    puts "-----|-----|-----"
    puts "     |     |   "
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |   "
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def [](key)
    @squares[key].marker
  end

  def unmarked_keys
    @squares.keys.select {|key| @squares[key].unmarked?}
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def identical_markers?(num, squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != num
    markers.min == markers.max
  end

  # returns winning marker or nil, meaning no one won
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if identical_markers?(3, squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each {|key| @squares[key] = Square.new}
  end

  def at_risk_square_key
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if identical_markers?(2, squares)
        return @squares.select {|k, v| line.include?(k) && v.unmarked?}.keys.first
      end
    end
    nil
  end

  def computer_winning_key
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if identical_markers?(2, squares) && squares.select(&:marked?).first.marker == TTTGame::COMPUTER_MARKER
        return @squares.select {|k, v| line.include?(k) && v.unmarked?}.keys.first
      end
    end
    nil
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_reader :marker
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end

  def increase_score
    @score += 1
  end

  def reset
    @score = 0
  end
end

class TTTGame
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
  end

  def clear
    system 'cls'
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts " "
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "You're marker is #{human.marker}.  Computer marker is #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def display_result
    clear_screen_and_display_board
    case board.winning_marker
    when HUMAN_MARKER
      puts "Congratulations, you won!"
    when COMPUTER_MARKER
      puts "Uh oh, computer won."
    else
      puts "The board is full."
    end
  end

  def calculate_result
    case board.winning_marker
    when HUMAN_MARKER
      human.increase_score
    when COMPUTER_MARKER
      computer.increase_score
    else
      nil
    end
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe!"
    puts "== Good Bye =="
  end

  def human_moves
    puts "Choose a square: #{board.unmarked_keys.join(', ')}"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    # if there is an at risk square, play there. otherwise, randomize.
    if board.computer_winning_key
      board[board.computer_winning_key] = computer.marker
    elsif board.at_risk_square_key
      board[board.at_risk_square_key] = computer.marker
    elsif board[5] == Square::INITIAL_MARKER
      board[5] = computer.marker
    else
      board[board.unmarked_keys.sample] = computer.marker
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end
    answer == 'y'
  end

  def reset
    board.reset
    human.reset
    computer.reset
    clear
  end

  def result
    display_result
    calculate_result
    display_points
  end

  def display_play_again_message
    puts "Let's play again"
    puts ""
  end

  def game_over?
    human.score == 5 || computer.score == 5
  end

  def display_points
    puts "You have #{human.score} points."
    puts "Computer has #{computer.score} points."
  end

  def ask_for_player_marker
    puts "Enter a single letter for your marker:"
    answer = nil
    loop do
      answer = gets.chomp
      break if /[a-zA-Z]/ =~ answer
      puts "It must be a letter A through Z."
    end

  end

  def play
    display_welcome_message
    ask_for_player_marker
    loop do
      loop do
      display_board
        loop do
          human_moves
          break if board.someone_won? || board.full?
          computer_moves
          break if board.someone_won? || board.full?
          clear_screen_and_display_board
        end
        result
        break if game_over?
        board.reset
      end
      break unless play_again?
      reset
      display_play_again_message
    end
    display_goodbye_message
  end
end

game = TTTGame.new
game.play

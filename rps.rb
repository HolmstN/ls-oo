class Move
  VALUES = %w(rock paper scissors)

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other_move)
    rock? && other_move.scissors? ||
      paper? && other_move.rock? ||
      scissors? && other_move.paper?
  end

  def <(other_move)
    rock? && other_move.paper? ||
      paper? && other_move.scissors? ||
      scissors? && other_move.rock?
  end

  def to_s
    @value
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, #{human.name}!"
    puts "You are playing against #{computer.name}."
    puts "First to 5 wins."
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Good bye!"
  end

  def won?(player_1, player_2)
    player_1.move > player_2.move
  end

  def display_winner
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."

    if won?(human, computer)
      puts "#{human.name} won!"
    elsif won?(computer, human)
      puts "#{computer.name} won."
    else
      puts "It's a tie."
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if %w(y n).include? answer.downcase
      puts "Must be y or n."
    end

    return false if answer.downcase == 'n'
    return true if answer.downcase == 'y'
  end

  def increment_score
    if won?(human, computer)
      human.score += 1
    elsif won?(computer, human)
      computer.score += 1
    end
  end

  def display_score
    puts "#{human.name}:  #{human.score}"
    puts "#{computer.name}:  #{computer.score}"
  end

  def display_game_winner
    if human.score == 5
      puts "#{human.name} has won the game!"
    else
      puts "#{computer.name} has won the game!"
    end
  end

  def game_over?
    human.score == 5 || computer.score == 5
  end

  def play
    display_welcome_message
    loop do
      loop do
        human.choose
        computer.choose
        display_winner
        increment_score
        display_score
        display_game_winner if game_over?
        break if game_over?
      end
      break unless play_again?
    end
    display_goodbye_message
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize(player_type = :human)
    @player_type = player_type
    set_name
    @score = 0
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, or scissors: "
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = %w(R2D2 Hal Wallee Sunny Num5).sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

RPSGame.new.play

class Card
  attr_reader :face, :suit, :value

  SUITS = %w(clubs spades diamonds hearts).freeze
  FACES = %w(2 3 4 5 6 7 8 9 10 jack queen ace king).freeze


  def initialize(suit, face)
    @suit = suit
    @face = face
    @value = valuate(face)
  end

  def to_s
    "#{@face} of #{@suit}"
  end

  private

  def valuate(card_face)
    case card_face
    when /[0-9]0?/
      card_face.to_i
    when 'jack'
      10
    when 'queen'
      10
    when 'king'
      10
    when 'ace'
      [11, 1]
    end
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    Card::SUITS.each do |suit|
      Card::FACES.each do |face|
        @cards << Card.new(suit, face)
      end
    end
  end

  def deal(player, num=1)
    num.times do
      random_card_index = cards.index(cards.sample)
      player.hand << cards[random_card_index]
      cards.delete_at(random_card_index)
    end
  end
end

class Participant
  attr_accessor :total
  attr_reader :hand

  def initialize
    @hand = []
    @total = 0
  end

  def make_total(hand)
    @total = get_total(hand).inject(:+)
  end

  def bust?
    total > 21
  end

  private

  def get_total(hand)
    total_array = []
    hand.each do |card|
      if card.value.is_a? Array
        choose_value = card.value.first + total > 21 ? card.value.last : card.value.first
        total_array << choose_value
      else
        total_array << card.value
      end
    end
    total_array
  end
end

class Player < Participant
  def ask_for_action
    puts ""
    puts "Would you like to hit or stay?"
    answer = nil
    loop do
      answer = gets.chomp
      break if hit?(answer) || stay?(answer)
      puts "That's not a valid input. Use hit(h) or stay(s)"
    end
    hit?(answer) ? 'h' : 's'
  end

  private

  def hit?(answer)
    answer.downcase == 'hit' || answer.downcase == 'h'
  end

  def stay?(answer)
    answer.downcase == 'stay' || answer.downcase == 's'
  end
end

class Dealer < Participant
  def should_draw?
    total < 17
  end
end

class TwentyOne
  attr_reader :player, :dealer, :deck

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def display_initial_cards
    display_player_cards
    puts "Dealer has:"
    puts "|| #{dealer.hand.first} ||"
  end

  def display_player_cards
    puts "You have:"
    player.hand.each { |card| puts "|| #{card} ||" }
    puts ""
  end

  def display_dealer_cards
    puts "Dealer has:"
    dealer.hand.each { |card| puts "|| #{card} ||" }
    puts ""
  end

  def display_final_result
    display_player_cards
    display_dealer_cards
    puts "You had #{player.total} points" unless player.total == 0
    puts "Dealer had #{dealer.total} points" unless dealer.total == 0
    if dealer.total < player.total
      puts "Dealer won this time."
    else
      puts "You won!"
    end
  end

  def display_bust_message
    display_final_result
    if player.bust?
      puts "You busted."
    else
      puts "Dealer busted!"
    end
  end

  def player_turn
    loop do
      response = player.ask_for_action
      if response == 'h'
        deck.deal(player)
        player.make_total(player.hand)
      end
      display_player_cards
      break if player.bust? || response == 's'
    end
    player.make_total(player.hand)
  end

  def dealer_wait
    3.times do
      sleep 1
      puts '.'
    end
  end

  def dealer_turn
    loop do
      dealer_wait
      if dealer.should_draw?
        deck.deal(dealer)
        dealer.make_total(dealer.hand)
      end
      display_dealer_cards
      break if dealer.bust? || !dealer.should_draw?
    end
    dealer.make_total(dealer.hand)
  end

  def check_for_win
    dealer.total
  end

  def game
    loop do
      deck.deal(player, 2)
      deck.deal(dealer, 2)
      display_initial_cards
      player_turn
      break if player.bust?
      dealer_turn
      break if dealer.bust?
    end
    if player.bust? || dealer.bust?
      display_bust_message
    else
      display_final_result
    end
  end
end

TwentyOne.new.game

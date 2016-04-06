class Card
  SUITS = %w(clubs spades diamonds hearts)
  FACES = %w(2 3 4 5 6 7 8 9 10 jack queen ace king)
  
  def initialize(suit, face)
    @suit = suit
    @face = face
  end
  
  def to_s
    "#{@face} of #{@suit}"
  end
end

class Deck
  attr_accessor :cards
  
  def initialize
    @cards = []
    SUITS.each do |suit|
      FACES.each do |face|
        @cards << Card.new(suit, face)
      end
    end
  end
  
  def deal(player)
    player.hand << cards
  end
    
end

class Participant
  
  def initialize
    @hand = []
  end
  
end

class Player < Participant
 
end

class Dealer < Participant

  def turn
  end
end

class RPSGame
  attr_reader :player, :dealer
  
  def initialize
    @player = Player.new
    @dealer = Dealer.new
  end
  
  def display_initial_cards
    
  end
  
  def display_final_result
  end
  
  def game
    deck.deal(player)
    deck.deal(dealer)
    display_initial_cards
    player.turn
    dealer.turn
    display_final_result
  end
end

RPSGame.new.game
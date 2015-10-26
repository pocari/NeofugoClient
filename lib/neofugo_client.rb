require 'json'

require 'websocket-client-simple'

require "neofugo_client/version"
require 'neofugo_client/util/util'
require 'neofugo_client/base'
require 'neofugo_client/test_connection'
require 'neofugo_client/test_rule_test'
require 'neofugo_client/test_practice'
require 'neofugo_client/strategy'

module NeofugoClient
  class PlayerInfo
    attr_accessor :name, :having_card_count, :ranking, :order_of_finish

    def to_s
      inspect
    end

    def inspect
      "(Player name:r#{@name}, having_card_count: #{@having_card_count}, ranking: #{@ranking}, order_of_finish: #{@order_of_finish})"
    end
  end

  class Message
    attr_accessor :your_num, :kind, :teban, :is_kakumei, :player_info, :deck, :ba, :yama, :history, :message
    def inspect
      "(your_num: #{@your_num}, kind: #{@kind}, teban: #{@teban}, is_kakumei: #{@is_kakumei}, player_info: #{@player_info}, deck: #{@deck}, ba: #{@ba}, yama: #{@yama}, history: #{@history}, message: #{@message})"
    end
  end

  class Card
    MARK_TO_VALUE = {
      '3' => 0,
      '4' => 1,
      '5' => 2,
      '6' => 3,
      '7' => 4,
      '8' => 5,
      '9' => 6,
      '0' => 7,
      'J' => 8,
      'Q' => 9,
      'K' => 10,
      'A' => 11,
      '2' => 12,
      'JK' => 13
    }
    attr_accessor :type, :mark, :value

    def to_card_string
      [@type, @mark].join
    end

    def to_s
      inspect
    end

    def inspect
      [@type, @mark, ["(", @value, ")"].join].join
    end

    class << self
      def to_card(e)
        c = Card.new
        if e == 'JK'
          c.type = 'JK'
          c.mark = nil
          c.value = MARK_TO_VALUE['JK']
        else
          c.type = e[0]
          c.mark = e[1]
          #p [:mark_to_value, e[1], MARK_TO_VALUE[e[1]], MARK_TO_VALUE]
          c.value = MARK_TO_VALUE[e[1]]
        end
        c
      end
    end
  end

  class History
    attr_accessor :player_num, :action, :cards
    def to_s
      inspect
    end
    def inspect
      "(Hist player_num: #{@player_num}, action: #{@action}, cards: #{@cards})"
    end
  end
end

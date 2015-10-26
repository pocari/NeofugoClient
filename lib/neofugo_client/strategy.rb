module NeofugoClient
  class Strategy
    def initialize(ws)
      @ws = ws
    end

    def put(cards)
      json = {
        "Kind": "Put",
        "Cards": cards.map(&:to_card_string).join(" ")
      }.to_json
      puts "put -----------------------------------"
      p json
      @ws.send(json)
    end

    def tweet(msg)
      @ws.send({
        "Kind": "Tweet",
        "Message": msg
      }.to_json)
    end

    def on_start(m)
    end

    def on_card_distributed(m)
    end

    def on_card_swapped(m)
    end

    def on_thinking(m)
    end

    def on_process_turn(m)
    end

    def on_cards_are_put(m)
    end

    def on_kakumei(m)
    end

    def on_nagare(m)
    end

    def on_agari(m)
    end

    def on_finish(m)
    end

    def on_tweet(m)
    end

    def on_exception(m)
      puts "exception -------------------------------------------------------"
      p m
    end
  end
end

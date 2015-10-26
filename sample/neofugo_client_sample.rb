$:.unshift File.expand_path '../lib', File.dirname(__FILE__)
require "neofugo_client"

require 'open-uri'

def get_new_room_id
  str = open('http://neof5master.azurewebsites.net/playroom/practice/B').read
  if /<pre>(.*)<\/pre>/ =~ str
    ws_url = Regexp.last_match(1)
    if /(P\d+)/ =~ ws_url
      Regexp.last_match(1)
    end
  end
end

class MyStrategy < NeofugoClient::Strategy
  def on_start(m)
    puts "start----------------------------------------"
    tweet("よろしくお願いします")
  end

  def on_finish(m)
    puts "finish----------------------------------------"
    p m
    tweet("お疲れ様でした")
  end

  def build_pattern(deck, n)
    deck.chunk{|e|
      e.value
    }.select {|e, ch|
      ch.size >= n
    }.map {|e, ch|
      [e, ch.first(n)]
    }
  end

  def on_process_turn(m)
    puts "process trun --------------------------------------------------->"
    p [:ba, m.ba]
    p [:deck, m.deck]

    last = m.ba.last
    cards = nil
    if !last
      cards = 4.downto(1).map{|e| build_pattern(m.deck, e)}.find{|e| e.size > 0}.first[1]
    else
      pattern = build_pattern(m.deck, last.size)

      n, cards = pattern.find {|e, ch|
        if m.is_kakumei
          last.first.value > e
        else
          last.first.value < e
        end
      }
    end

    p [:cards, cards]
    tweet("action: #{cards}")
    put(cards ? cards : [])
  end
end

room_id = ARGV.shift || get_new_room_id
client = NeofugoClient::TestPractice.create do |c|
  c.verbose = true
  c.name = 'Sample'
  c.room_id = room_id
  c.strategy_class = MyStrategy
end

puts "playroom id: #{room_id}"
client.run


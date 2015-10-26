module NeofugoClient
  using Util::StringEx
  class Base
    class << self
      def create(opts={})
        client = self.new(opts)
        yield client
        client
      end
    end

    attr_accessor :host, :port, :verbose, :strategy_class
    def initialize(opts = {})
      @host = opts['host'] || 'neof5master.azurewebsites.net'
      @port = opts['port'] || 80
      @ws_handler = nil
      @finished = false
    end

    def run()
      @ws = WebSocket::Client::Simple.connect(build_url)
      @strategy = @strategy_class.new(@ws)
      handle

      loop do
        if @finished
          @ws.close
          break
        end
      end
    end

    def handle
      this = self
      ws = @ws
      ws.on :message do |msg|
        if msg.data == 'ping'
          ws.send(nil, :type => :pong)
        else
          this.on_message(msg)
        end
      end

      ws.on :open do
        this.on_open
      end

      ws.on :close do |e|
        this.on_close(e)
      end

      ws.on :error do |e|
        this.on_error(e)
      end
    end

    def on_open()
    end

    def on_close(e)
    end

    def on_error(e)
    end

    def on_message(msg)
      begin
        obj = parse_message(msg)
        dispatch_by_kind(obj)
      rescue => e
        STDERR.puts e
        STDERR.puts e.backtrace.join("\n")
      end
    end

    def build_base_websocket_url()
      "ws://#{@host}:#{@port}"
    end

    def list_to_card_list(card_list_string)
      card_list_string.split(/ /).map {|e|
        Card.to_card(e)
      }
    end

    def dispatch_by_kind(obj)
      result = @strategy.send("on_" + obj.kind.pascal_to_snake, obj)
      if obj.kind == "Finish"
        @finished = true
      end
    end

    def parse_message(msg)
      begin
        j = JSON.parse(msg.data)

        m = Message.new
        m.kind = j['Kind']
        if %w(Tweet Exception).include?(j['Kind'])
          m.message = j['Message']
          return m
        end

        m.your_num = j["YourNum"]
        m.teban = j['Teban']
        m.is_kakumei = j['IsKakumei']
        m.player_info = j['PlayerInfo'].map {|e|
          pi = PlayerInfo.new
          pi.name = e['Name']
          pi.having_card_count = e['HavingCardCount']
          pi.ranking = e['Ranking']
          pi.order_of_finish = e['OrderOfFinish']
          pi
        }
        m.deck = list_to_card_list(j['Deck'])
        #p [:ba_raw, j['Ba']]
        m.ba = j['Ba'].map{|e| list_to_card_list(e)}
        m.yama = j['Yama']
        m.history = j['History'].map {|e|
          a = History.new
          if e[0] == '/'
            a.action = :nagare
          else
            a.player_num = e[0].to_i
            if e[2] == 'P'
              a.action = :pass
            elsif e[2] == 'A'
              a.action = :agari
            else
              a.action = :player_action
            end
            if /\[([^\]]+)\]/ =~ e
              a.cards = list_to_card_list(Regexp.last_match(1))
            end
          end
          a
        }
        m
      rescue => e
        p e
      end
    end
  end
end


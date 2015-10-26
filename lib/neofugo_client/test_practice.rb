module NeofugoClient
  class TestPractice < Base
    attr_accessor :name, :room_id
    def initialize(opts = {})
      super(opts)
    end

    def build_url()
      build_base_websocket_url + "/test/practice/#{@room_id}?name=#{@name}"
    end
  end
end


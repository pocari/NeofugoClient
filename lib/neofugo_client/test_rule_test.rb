module NeofugoClient
  class TestRuleTest < Base
    attr_accessor :name, :room_id
    def initialize(opts = {})
      super(opts)
    end

    def build_url()
      build_base_websocket_url + "/test/ruletest/#{@room_id}?name=#{@name}"
    end
  end
end


module NeofugoClient
  class TestConnection < Base
    attr_accessor :name
    def initialize(opts = {})
      super(opts)
    end

    def build_url()
      build_base_websocket_url + "/test/connection?name=#{@name}"
    end
  end
end


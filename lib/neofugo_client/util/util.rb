module NeofugoClient
  module Util
    module StringEx
      refine String do
        def pascal_to_snake
          self.scan(/[A-Z][^A-Z]+/).map(&:downcase).join("_")
        end
      end
    end
  end
end

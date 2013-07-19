module Seam
  class Flow
    attr_reader :steps

    def initialize
      @steps = []
    end

    def method_missing(meth, *args, &blk)
      @steps << Object.new
    end
  end
end

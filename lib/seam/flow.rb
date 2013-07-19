module Seam
  class DoStep
    attr_accessor :name
  end

  class Flow
    attr_reader :steps

    def initialize
      @steps = []
    end

    def method_missing(meth, *args, &blk)
      step = DoStep.new
      step.name = meth.to_s
      @steps << step
    end
  end
end

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
      step.name = "do_something"
      @steps << step
    end
  end
end

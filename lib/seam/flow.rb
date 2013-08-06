module Seam
  class Flow

    def initialize
      @steps = []
    end

    def method_missing(meth, *args, &blk)
      @steps << [meth.to_s, args]
    end

    def steps
      @steps.map do |x|
        step = Seam::Step.new
        step.name = x[0]
        if step.name.index('branch_on')
          step.name += "_#{x[1][0]}"
        end
        step
      end
    end
  end
end

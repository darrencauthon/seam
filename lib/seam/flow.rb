module Seam
  class Flow

    def initialize
      @steps = []
    end

    def method_missing(meth, *args, &blk)
      @steps << [meth.to_s, args]
    end

    def start data
      effort = Seam::Effort.new
      effort.id = SecureRandom.uuid.to_s
      effort.created_at = Time.now
      effort
    end

    def steps
      @steps.map do |x|
        step = Seam::Step.new
        step.name = x[0]
        step.type = "do"
        step.arguments = x[1]
        if step.name.index('branch_on')
          step.name += "_#{x[1][0]}"
          step.type = "branch"
        end
        step
      end
    end
  end
end

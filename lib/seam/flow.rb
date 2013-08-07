module Seam
  class Flow

    def initialize
      @steps = []
    end

    def method_missing(meth, *args, &blk)
      @steps << [meth.to_s, args]
    end

    def start(data = {})
      effort = Seam::Effort.new
      effort.id              = SecureRandom.uuid.to_s
      effort.created_at      = Time.parse(Time.now.to_s)
      effort.next_execute_at = Time.parse(Time.now.to_s)
      effort.next_step       = self.steps.first.name.to_s
      effort.flow            = ActiveSupport::HashWithIndifferentAccess.new self.to_hash
      effort.data            = ActiveSupport::HashWithIndifferentAccess.new data
      effort.save
      effort
    end

    def to_hash
      {
        steps: self.steps.map { |x| x.to_hash }
      }
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

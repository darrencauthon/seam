module Seam
  class Flow

    def initialize
      @steps = {}
    end

    def method_missing(meth, *args, &blk)
      return false if @steps[meth.to_s]
      @steps[meth.to_s] = args
      true
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
      @steps.each.map do |key, value|
        step = Seam::Step.new
        step.name = key
        step.type = "do"
        step.arguments = value
        if step.name.index('branch_on')
          step.name += "_#{value[0]}"
          step.type = "branch"
        end
        step
      end
    end
  end
end

module Seam
  class Flow

    def initialize
      @steps = {}
    end

    def method_missing(meth, *args, &blk)
      meth = meth.to_s
      return false if @steps[meth]
      @steps[meth] = args
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
      { steps: self.steps.map { |x| x.to_hash } }
    end

    def steps
      @steps.each.map do |name, arguments|
        Seam::Step.new( { name:       name,
                          type:      'do',
                          arguments: arguments } )

      end
    end
  end
end

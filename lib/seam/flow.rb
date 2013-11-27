module Seam
  class Flow

    attr_accessor :stamp_data_history

    def initialize
      @steps = []
      @stamp_data_history = false
    end

    def method_missing(meth, *args, &blk)
      meth = meth.to_s
      @steps << { name: meth, arguments: args }
      true
    end

    def start(data = {})
      Seam::Effort.create( {
                             id:              SecureRandom.uuid.to_s,
                             created_at:      Time.parse(Time.now.to_s),
                             next_execute_at: Time.parse(Time.now.to_s),
                             next_step:       self.steps.first.name.to_s,
                             flow:            the_flow_from,
                             data:            ActiveSupport::HashWithIndifferentAccess.new(data)
                           } )
    end

    def the_flow_from
      hash = self.to_hash
      flow = ActiveSupport::HashWithIndifferentAccess.new hash
      flow['steps'].each do |step|
        step['id'] = SecureRandom.uuid.to_s
      end
      flow
    end

    def to_hash
      { 
        steps: self.steps.map { |x| x.to_hash },
        stamp_data_history: @stamp_data_history
      }
    end

    def steps
      @steps.each.map do |step|
        Seam::Step.new( { name:      step[:name],
                          type:      'do',
                          arguments: step[:arguments] } )

      end
    end
  end
end

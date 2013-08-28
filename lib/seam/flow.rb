module Seam
  class Flow

    def initialize
      @steps = []
    end

    def method_missing(meth, *args, &blk)
      meth = meth.to_s
      @steps << [meth, args]
      true
    end

    def start(data = {})
      Seam::Effort.create( {
                             id:              SecureRandom.uuid.to_s,
                             created_at:      Time.parse(Time.now.to_s),
                             next_execute_at: Time.parse(Time.now.to_s),
                             next_step:       self.steps.first.name.to_s,
                             flow:            ActiveSupport::HashWithIndifferentAccess.new(self.to_hash),
                             data:            ActiveSupport::HashWithIndifferentAccess.new(data)
                           } )
    end

    def to_hash
      { steps: self.steps.map { |x| x.to_hash } }
    end

    def steps
      @steps.each.map do |values|
        name      = values[0]
        arguments = values[1]
        Seam::Step.new( { name:       name,
                          type:      'do',
                          arguments: arguments } )

      end
    end
  end
end

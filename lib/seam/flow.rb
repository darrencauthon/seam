require 'json'

module Seam
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

    def serialize
      JSON.generate( { name: '', steps: [] } )
    end

    def self.deserialize input
      Seam::Flow.new
    end
  end
end

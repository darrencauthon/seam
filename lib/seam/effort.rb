module Seam
  class Effort
    attr_accessor :completed_steps
    attr_accessor :created_at
    attr_accessor :id

    def initialize
      @completed_steps = []
    end
  end
end

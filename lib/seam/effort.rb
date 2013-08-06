module Seam
  class Effort
    attr_accessor :completed_steps
    attr_accessor :created_at
    attr_accessor :id
    attr_accessor :next_execute_at
    attr_accessor :next_step

    def initialize
      @completed_steps = []
    end
  end
end

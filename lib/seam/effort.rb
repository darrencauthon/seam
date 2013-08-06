module Seam
  class Effort
    attr_accessor :completed_steps
    attr_accessor :id

    def initialize
      @completed_steps = []
      @id = SecureRandom.uuid.to_s
    end
  end
end

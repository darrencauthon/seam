module Seam
  class WaitWorker < ::Seam::Worker
    def initialize
      handles :wait
    end

    def process
      if effort.history.count == 0
        try_again_in 3.days
      end
    end
  end
end

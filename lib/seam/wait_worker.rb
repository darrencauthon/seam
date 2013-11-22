module Seam
  class WaitWorker < ::Seam::Worker
    def initialize
      handles :wait
    end

    def process
      if effort.history.count == 0 || effort.history.last[:step] != 'wait'
        try_again_in current_step[:arguments][0]
      end
    end
  end
end

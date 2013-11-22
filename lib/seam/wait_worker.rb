module Seam
  class WaitWorker < ::Seam::Worker
    def initialize
      handles :wait
    end

    def process
      try_again_in the_appropriate_amount_of_time if we_should_wait
    end

    private

    def we_should_wait
      first = effort.history.count == 0 || 
              effort.history.last[:step] != 'wait'
      if (effort.created_at + the_appropriate_amount_of_time) <= Time.now
        return false
      end
      first
    end

    def the_appropriate_amount_of_time
      current_step[:arguments][0]
    end
  end
end

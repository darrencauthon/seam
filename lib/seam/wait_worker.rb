module Seam

  class WaitWorker < ::Seam::Worker

    def initialize
      handles :wait
    end

    def process
      move_to_next_step( { on: the_time_to_move_on } )
    end

    private

    def the_time_to_move_on
      time_of_last_execution + the_amount_of_time_to_wait
    end

    def the_amount_of_time_to_wait
      current_step[:arguments][0]
    end

    def time_of_last_execution
      return effort.created_at if effort.history.count == 0
      effort.history.last[:stopped_at]
    end

  end

end

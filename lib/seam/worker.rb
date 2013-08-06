module Seam
  class Worker
    def for(step)
      @step = step
    end

    def execute effort
      @current_effort = effort
      process
    end

    def move_to_next_step
      @current_effort.next_step = @current_effort.flow[:steps].last[:name]
      @current_effort.save
    end

    def try_again_in seconds
      @current_effort.next_execute_at = Time.now + seconds
      @current_effort.save
    end
  end
end

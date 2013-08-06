module Seam
  class Worker
    def for(step)
      @step = step
    end

    def execute effort
      @current_run = { started_at: Time.now, step: @step.to_s }
      @current_effort = effort
      process
      @current_run[:stopped_at] = Time.now
      @current_effort.history << @current_run
      @current_effort.save
    end

    def execute_all
      Seam::Effort.find_all_by_step(@step.to_s).each do |effort|
        execute effort
      end
    end

    def move_to_next_step
      @current_effort.completed_steps << @current_effort.next_step

      steps = @current_effort.flow['steps'].map { |x| x['name'] }

      next_step = steps[@current_effort.completed_steps.count]
      @current_effort.next_step = next_step
      @current_effort.save
    end

    def try_again_in seconds
      @current_effort.next_execute_at = Time.now + seconds
      @current_effort.save
    end
  end
end

module Seam
  class Worker
    def handles(step)
      @step = step
    end

    def effort
      @current_effort
    end

    def history
      @current_run
    end

    def execute effort
      @current_run = HashWithIndifferentAccess.new( { 
                                                      started_at: Time.now,
                                                      step: @step.to_s, 
                                                      data_before: effort.data.clone,
                                                    } )
      @current_effort = effort
      process
      history[:data_after] = effort.data.clone
      history[:stopped_at] = Time.now
      effort.history << history
      effort.save
    end

    def execute_all
      Seam::Effort.find_all_by_step(@step.to_s).each do |effort|
        execute effort
      end
    end

    def eject
      history[:result] = "eject"
      mark_effort_as_complete
      effort.next_step    = nil
      effort.save
    end

    def move_to_next_step
      history[:result] = "move_to_next_step"
      effort.completed_steps << effort.next_step

      steps = effort.flow['steps'].map { |x| x['name'] }

      next_step = steps[effort.completed_steps.count]
      effort.next_step = next_step
      mark_effort_as_complete if next_step.nil?
      effort.save
    end

    def try_again_in seconds
      try_again_on = Time.now + seconds

      history[:result] = "try_again_in"
      history[:try_again_on] = try_again_on

      effort.next_execute_at = try_again_on
      effort.save
    end

    private

    def mark_effort_as_complete
      effort.complete     = true
      effort.completed_at = Time.now
    end
  end
end

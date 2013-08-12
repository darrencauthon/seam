module Seam
  class Worker
    def handles step
      @step = step
    end

    def execute effort
      set_current_effort effort
      before_process
      process
      after_process
    end

    def execute_all
      efforts_to_execute.each { |e| execute e }
    end

    def eject
      @operation_to_execute = :eject
    end

    def move_to_next_step
      @operation_to_execute = :move_to_next_step
    end

    def try_again_in seconds
      @operation_to_execute = :try_again_in
      operation_args[:seconds] = seconds
    end

    attr_accessor :operation_args
    def operation_args
      @operation_args ||= {}
    end

    def operations
      {
        try_again_in: -> do
                           seconds = operation_args[:seconds]
                           try_again_on = Time.now + seconds

                           history[:result] = "try_again_in"
                           history[:try_again_on] = try_again_on

                           effort.next_execute_at = try_again_on
                           effort.save
                         end,
        move_to_next_step: -> do
                                history[:result] = "move_to_next_step"
                                effort.completed_steps << effort.next_step

                                steps = effort.flow['steps'].map { |x| x['name'] }

                                next_step = steps[effort.completed_steps.count]
                                effort.next_step = next_step
                                mark_effort_as_complete if next_step.nil?
                                effort.save
                              end,
        eject: -> do
                    history[:result] = "eject"
                    mark_effort_as_complete
                    effort.next_step = nil
                    effort.save
                  end
      }
    end

    def effort
      @current_effort
    end

    def history
      @current_run
    end

    private

    def mark_effort_as_complete
      effort.complete     = true
      effort.completed_at = Time.now
    end

    def set_current_effort effort
      @current_effort = effort
    end

    def before_process
      run = { 
              started_at: Time.now,
              step: @step.to_s, 
              data_before: effort.data.clone,
            }
      @current_run = HashWithIndifferentAccess.new run
    end

    def after_process
      execute_the_appropriate_operation
      stamp_the_new_history_record
      save_the_effort
    end

    def efforts_to_execute
      Seam::Effort.find_all_by_step(@step.to_s)
    end

    def execute_the_appropriate_operation
      operations[@operation_to_execute].call if @operation_to_execute
    end

    def stamp_the_new_history_record
      history[:data_after] = effort.data.clone
      history[:stopped_at] = Time.now
      effort.history << history
    end

    def save_the_effort
      effort.save
    end
  end
end

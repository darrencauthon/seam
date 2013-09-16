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
      @operation_to_execute    = :try_again_in
      operation_args[:seconds] = seconds
    end

    def try_again_on time
      @operation_to_execute = :try_again_on
      operation_args[:time] = time
    end

    attr_accessor :operation_args
    def operation_args
      @operation_args ||= {}
    end

    def operations
      {
        try_again_in:      -> do
                                seconds = operation_args[:seconds]
                                try_again_on = Time.now + seconds

                                history[:try_again_on] = try_again_on

                                effort.next_execute_at = try_again_on
                              end,
        try_again_on:      -> do
                                history[:try_again_on] = operation_args[:time]
                                effort.next_execute_at = operation_args[:time]
                              end,
        move_to_next_step: -> do
                                effort.completed_steps << effort.next_step

                                steps = effort.flow['steps'].map { |x| x['name'] }
                                next_step = steps[effort.completed_steps.count]

                                effort.next_step = next_step
                                mark_effort_as_complete if next_step.nil?
                              end,
        eject:             -> { mark_effort_as_complete }
      }
    end

    def effort
      @current_effort
    end

    def history
      @current_run
    end

    def step
      s = @step || self.class.name.underscore.gsub('_worker', '')
      s.to_s
    end

    def current_step
      effort.flow["steps"][effort.completed_steps.count]
    end

    private

    def mark_effort_as_complete
      effort.next_step    = nil
      effort.complete     = true
      effort.completed_at = Time.now
    end

    def set_current_effort effort
      @current_effort = effort
    end

    def before_process
      run = { 
              started_at:  Time.now,
              step:        step, 
              data_before: stamping_the_history? ? effort.data.clone : nil
            }
      @current_run = HashWithIndifferentAccess.new run
    end

    def after_process
      execute_the_appropriate_operation
      stamp_the_new_history_record
      save_the_effort
    end

    def efforts_to_execute
      Seam::Effort.find_all_by_step step
    end

    def execute_the_appropriate_operation
      @operation_to_execute ||= :move_to_next_step
      operations[@operation_to_execute].call
    end

    def stamp_the_new_history_record
      history[:result]     = @operation_to_execute
      history[:stopped_at] = Time.now

      if stamping_the_history?
        history[:data_after] = effort.data.clone
      end

      effort.history << history
    end

    def stamping_the_history?
      effort.flow['stamp_data_history']
    end

    def save_the_effort
      effort.save
    end
  end
end

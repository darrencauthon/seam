module Seam
  class Effort
    attr_accessor :completed_steps
    attr_accessor :created_at
    attr_accessor :complete
    attr_accessor :id
    attr_accessor :next_execute_at
    attr_accessor :next_step
    attr_accessor :flow
    attr_accessor :data
    attr_accessor :history

    class << self

      def find effort_id
        Seam::Persistence.find_by_effort_id effort_id
      end

      def find_all_by_step step
        Seam::Persistence.find_all_pending_executions_by_step step
      end

      def parse document
        effort = Effort.new
        effort.id              = document['id']
        effort.created_at      = Time.parse(document['created_at'].to_s)
        effort.next_execute_at = document['next_execute_at']
        effort.next_step       = document['next_step']
        effort.flow            = HashWithIndifferentAccess.new document['flow']
        effort.data            = HashWithIndifferentAccess.new document['data']
        effort.history         = document['history'].map { |x| HashWithIndifferentAccess.new x }
        effort.completed_steps = document['completed_steps']
        effort.complete        = document['complete']
        effort
      end

    end
    
    def initialize
      @completed_steps = []
      @history         = []
      @complete        = false
    end

    def save
      existing_record = Seam::Effort.find self.id
      if existing_record
        Seam::Persistence.save self
      else
        Seam::Persistence.create self
      end
    end

    def complete?
      complete
    end

    def to_hash
      {
        id:              self.id,
        created_at:      self.created_at,
        completed_steps: self.completed_steps,
        next_execute_at: self.next_execute_at,
        next_step:       self.next_step,
        flow:            self.flow,
        data:            self.data,
        history:         self.history,
        complete:        self.complete,
      }
    end

    def clone
      Seam::Effort.parse HashWithIndifferentAccess.new(self.to_hash)
    end
  end
end

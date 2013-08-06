module Seam
  class Effort
    attr_accessor :completed_steps
    attr_accessor :created_at
    attr_accessor :id
    attr_accessor :next_execute_at
    attr_accessor :next_step
    attr_accessor :flow
    attr_accessor :data

    class << self

      attr_accessor :session

      def set_session session
        @session = session
      end

      def find effort_id
        document = @session['efforts'].find( { id: effort_id } ).first
        return nil unless document
        self.parse document
      end

      def find_all_by_step step
        @session['efforts'].find( { next_step: step } )
          .map { |x| Seam::Effort.parse x }
      end

      def parse document
        effort = Effort.new
        effort.id              = document['id']
        effort.created_at      = Time.parse(document['created_at'].to_s)
        effort.next_execute_at = document['next_execute_at']
        effort.next_step       = document['next_step']
        effort.flow            = document['flow']
        effort.data            = document['data']
        effort.completed_steps = document['completed_steps']
        effort
      end

    end
    
    def initialize
      @completed_steps = []
    end

    def save
      existing_record = Seam::Effort.find self.id
      if existing_record
        Seam::Effort.session['efforts'].find( { id: self.id } )
            .update("$set" => self.to_hash)
      else
        Seam::Effort.session['efforts'].insert(self.to_hash)
      end
    end

    def to_hash
      {
        id:              self.id,
        created_at:      self.created_at,
        completed_steps: self.completed_steps,
        next_execute_at: self.next_execute_at,
        next_step:       self.next_step,
        flow:            self.flow,
        data:            self.data
      }
    end
  end
end

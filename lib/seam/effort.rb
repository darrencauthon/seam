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

      attr_accessor :collection

      def set_collection collection
        @collection = collection
      end

      def find effort_id
        document = collection.find( { id: effort_id } ).first
        return nil unless document
        self.parse document
      end

      def find_all_by_step step
        collection
          .find( { next_step: step, next_execute_at: { '$lte' => Time.now } } )
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
        effort.history         = document['history']
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
        Seam::Effort.collection.find( { id: self.id } )
            .update("$set" => self.to_hash)
      else
        Seam::Effort.collection.insert(self.to_hash)
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
  end
end

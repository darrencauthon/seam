module Seam
  class Effort
    attr_accessor :completed_steps
    attr_accessor :created_at
    attr_accessor :id
    attr_accessor :next_execute_at
    attr_accessor :next_step

    class << self

      attr_accessor :session

      def set_session session
        @session = session
      end

      def find effort_id
        document = @session['efforts'].find( { id: effort_id } ).first
        return nil unless document
        effort = Effort.new
        effort.id = document['id']
        effort
      end
    end
    
    def initialize
      @completed_steps = []
    end

    def save
      Seam::Effort.session['efforts'].insert({
                                               id: self.id
                                             })
    end
  end
end

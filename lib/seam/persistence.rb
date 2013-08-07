module Seam
  module Persistence
    def self.find_by_effort_id effort_id
      document = Seam::MongoDb.collection.find( { id: effort_id } ).first
      return nil unless document
      Seam::Effort.parse document
    end

    def self.find_all_pending_executions_by_step step
      Seam::MongoDb.collection
        .find( { next_step: step, next_execute_at: { '$lte' => Time.now } } )
        .map { |x| Seam::Effort.parse x }
    end

    def self.save effort
      Seam::MongoDb.collection.find( { id: effort.id } )
          .update("$set" => effort.to_hash)
    end

    def self.create effort
      Seam::MongoDb.collection.insert(effort.to_hash)
    end
  end
end

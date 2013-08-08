module Seam
  module Persistence
    def self.find_by_effort_id effort_id
      effort = Seam::InMemory.records.select { |x| x.id == effort_id }.first
      return nil unless effort
      effort.clone
      #document = Seam::MongoDb.collection.find( { id: effort_id } ).first
      #return nil unless document
      #Seam::Effort.parse document
    end

    def self.find_all_pending_executions_by_step step
      Seam::InMemory.records
        .select { |x| x.next_step == step && x.next_execute_at <= Time.now }
        .map { |x| x.clone }
      #Seam::MongoDb.collection
        #.find( { next_step: step, next_execute_at: { '$lte' => Time.now } } )
        #.map { |x| Seam::Effort.parse x }
    end

    def self.save effort
      old_record = find_by_effort_id effort.id
      if old_record
        Seam::InMemory.records = Seam::InMemory.records.select { |x| x.id != effort.id }.to_a
      end
      create effort
      #Seam::MongoDb.collection.find( { id: effort.id } )
      #    .update("$set" => effort.to_hash)
    end

    def self.create effort
      Seam::InMemory.records = [Seam::InMemory.records, effort].flatten
      #Seam::MongoDb.collection.insert(effort.to_hash)
    end

    def self.all
      Seam::InMemory.records.to_a
    end

    def self.destroy
      Seam::InMemory.records = []
    end
  end
end

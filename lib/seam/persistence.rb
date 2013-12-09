module Seam
  module Persistence
    def self.find_by_effort_id effort_id
      effort = Seam::InMemory.records.select { |x| x.id == effort_id }.first
      return nil unless effort
      effort.clone
    end

    def self.find_all_pending_executions_by_step step
      Seam::InMemory.records
        .select { |x| x.next_step == step && x.next_execute_at <= Time.now }
        .map { |x| x.clone }
    end

    def self.find_something_to_do
      Seam::InMemory.records
        .select { |x| x.complete.nil? || x.complete == false }
        .select { |x| x.next_execute_at <= Time.now }
        .select { |x| x.next_step != nil }
        .map    { |x| x.clone }
    end

    def self.save effort
      old_record = find_by_effort_id effort.id
      if old_record
        Seam::InMemory.records = Seam::InMemory.records.select { |x| x.id != effort.id }.to_a
      end
      create effort
    end

    def self.create effort
      Seam::InMemory.records = [Seam::InMemory.records, effort].flatten
    end

    def self.all
      Seam::InMemory.records.to_a
    end

    def self.destroy
      Seam::InMemory.records = []
    end
  end
end

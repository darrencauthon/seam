module Seam
  module InMemory
    class << self
      def records
        @records ||= []
      end

      def records=(records)
        @records = records
      end
    end
  end
end

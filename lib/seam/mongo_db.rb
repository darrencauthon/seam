module Seam
  module MongoDb

    def self.collection
      @collection
    end

    def self.set_collection collection
      @collection = collection
    end
  end
end

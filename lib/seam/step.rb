module Seam
  class Step
    attr_accessor :name
    attr_accessor :type
    attr_accessor :arguments

    def to_hash
      {
        name: name,
        type: type,
        arguments: arguments
      }
    end
  end
end

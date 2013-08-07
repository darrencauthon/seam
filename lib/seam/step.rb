module Seam
  class Step
    attr_accessor :name
    attr_accessor :type
    attr_accessor :arguments

    def to_hash
      {
        name: name,
        type: type,
        arguments: HashWithIndifferentAccess.new(arguments || {})
      }
    end
  end
end

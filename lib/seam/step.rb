module Seam
  class Step
    attr_accessor :name
    attr_accessor :type
    attr_accessor :arguments

    def initialize(args = {})
      args.each { |k, v| self.send "#{k}=".to_sym, v }
    end

    def to_hash
      {
        name: name,
        type: type,
        arguments: HashWithIndifferentAccess.new(arguments || {})
      }
    end
  end
end

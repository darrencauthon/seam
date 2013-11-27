module Seam
  class Step
    attr_accessor :id
    attr_accessor :name
    attr_accessor :type
    attr_accessor :arguments

    def initialize(args = {})
      args.each { |k, v| self.send "#{k}=".to_sym, v }
    end

    def to_hash
      {
        id:        id,
        name:      name,
        type:      type,
        arguments: get_arguments
      }
    end

    private

    def get_arguments
      arguments.map do |x|
        if x.is_a? Hash
          HashWithIndifferentAccess.new(x)
        else
          x
        end
      end
    end
  end
end

module Seam
  class WaitWorker < ::Seam::Worker
    def initialize
      handles :wait
    end
  end
end

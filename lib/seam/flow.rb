module Seam
  class Flow
    def method_missing(meth, *args, &blk)
      puts meth.inspect
    end

    def steps
      (1..3).to_a
    end
  end
end

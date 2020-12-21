module Stats
  class All
    attr_reader :params

    def initialize(params = {})
      @params = OpenStruct.new(params)
    end
  end
end

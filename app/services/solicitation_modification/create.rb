module SolicitationModification
  class Create < Base
    def self.call(params)
      self.new(Solicitation.new, params).call
    end
  end
end

module ApiConsumption::Models
  class Company::Base < Base
    def name
      raise 'A definir dans la classe enfant'
    end

    def date_de_creation
      I18n.l(Time.strptime(date_creation.to_s, '%s').in_time_zone.to_date)
    end

    def naf_libelle
      raise 'A definir dans la classe enfant'
    end
  end
end

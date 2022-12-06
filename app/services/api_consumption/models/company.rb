module ApiConsumption::Models
  class Company < Base
    def name
      raise 'mising'
    end

    def inscrit_rcs
      return false if rcs.blank?
      rcs["error"].nil?
    end

    def inscrit_rm
      return false if rm.blank?
      rm["error"].nil?
    end

    def date_de_creation
      I18n.l(Time.strptime(date_creation.to_s, '%s').in_time_zone.to_date)
    end

    def naf_libelle
      raise 'mising'
    end
  end
end

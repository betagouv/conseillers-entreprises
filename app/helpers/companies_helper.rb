# frozen_string_literal: true

module CompaniesHelper
  def date_from_timestamp(timestamp)
    I18n.l(Time.strptime(timestamp.to_s, '%s').in_time_zone.to_date) rescue nil
  end

  def inscription_registres(company)
    rcs = [I18n.t('activerecord.attributes.company.inscrit_rcs'), I18n.t(company.inscrit_rcs.present?, scope: [:boolean, :text])].join(" : ")
    rm =  [t('activerecord.attributes.company.inscrit_rm'), t(company.inscrit_rm.present?, scope: [:boolean, :text])].join(" : ")
    [rcs, rm].join(" / ")
  end
end

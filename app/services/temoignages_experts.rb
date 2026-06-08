module TemoignagesExperts
  Temoignage = Data.define(:title, :subtitle, :institution, :expert, :publication_date, :initial_publication_date, :landing_subject, :mtm_kwd, :voir_aussi)
  def self.data
    @data ||= begin
      data = self.load.deep_symbolize_keys
      institutions_names = Institution.where(slug: data.values.pluck(:institution)).pluck(:slug, :name).to_h
      data.transform_values! do |values|
        values.merge(institution: institutions_names[values[:institution]])
      end
      data.transform_values!{ Temoignage.new(**it) }
      data
    end
  end

  def self.load
    YAML.load_file("#{Rails.root.join('config', 'data', 'temoignages_experts.yml')}", permitted_classes: [Date])
  end
end

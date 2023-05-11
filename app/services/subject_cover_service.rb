class SubjectCoverService
  def call(antennes = Antenne.not_deleted.all); end

  private

  def detect_anomalie(antenne, subject)
    # Todo ajouter la couverture régionale et nationale
    institutions_subjects = antenne.institutions_subjects.find_by(subject: subject)
    expert_subject = antenne.experts_subjects.where(institution_subject: institutions_subjects)
    experts_with_specific_territories = antenne.experts.where.associated(:communes)
    experts_communes = antenne.experts.filter_map(&:communes).compact.flatten

    # Si le sujet n'est pas couvert par l'antenne
    if experts_with_specific_territories.blank? && expert_subject.blank?
      :less
    # Si plusieurs experts couvrent un même sujet
    elsif experts_with_specific_territories.blank? && expert_subject.size > 1
      :more
    # si plusieurs experts avec des territoires spécifiques couvrent le même sujet
    elsif experts_with_specific_territories.present? && experts_communes.size > antenne.communes.size
      :more_specific
    # Si tous le territoire n’est pas entièrement couvert par les experts
    elsif experts_with_specific_territories.present? && !Utilities::Arrays.same?(antenne.communes, experts_communes)
      :less_specific
    end
  end
end

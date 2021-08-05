# == Schema Information
#
# Table name: landings
#
#  id                           :bigint(8)        not null, primary key
#  custom_css                   :string
#  emphasis                     :boolean          default(FALSE)
#  home_description             :text             default("")
#  home_sort_order              :integer
#  home_title                   :string           default("")
#  layout                       :string           default("multiple_steps")
#  logos                        :string
#  main_logo                    :string
#  message_under_landing_topics :string
#  meta_description             :string
#  meta_title                   :string
#  partner_url                  :string
#  slug                         :string           not null
#  subtitle                     :string
#  title                        :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  institution_id               :bigint(8)
#
# Indexes
#
#  index_landings_on_institution_id  (institution_id)
#  index_landings_on_slug            (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#

class Landing < ApplicationRecord
  ## Associations
  #
  has_many :landing_joint_themes, -> { order(:position) }, inverse_of: :landing, dependent: :destroy
  has_many :landing_themes, through: :landing_joint_themes, inverse_of: :landings
  has_many :landing_subjects, through: :landing_themes, inverse_of: :landing_theme

  belongs_to :institution, inverse_of: :landings, optional: true
  has_many :landing_topics, inverse_of: :landing, :dependent => :destroy
  has_many :landing_options, inverse_of: :landing, :dependent => :destroy

  has_many :solicitations, primary_key: :slug, foreign_key: :landing_slug, inverse_of: :landing
  accepts_nested_attributes_for :landing_topics, :landing_options, :landing_joint_themes, allow_destroy: true

  before_save :set_emphasis

  ## Scopes
  #
  scope :ordered_for_home, -> { where.not(home_sort_order: nil).order(:home_sort_order) }
  scope :emphasis, -> { where(emphasis: true) }

  def to_s
    slug
  end

  def to_param
    slug
  end

  private

  def set_emphasis
    if emphasis
      Landing.where.not(id: id).update_all(emphasis: false)
    end
  end
end

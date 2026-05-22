require 'rails_helper'

RSpec.describe SolicitationMailTemplate do
  describe 'validations' do
    subject { build(:solicitation_mail_template) }

    it { is_expected.to validate_presence_of(:email_type) }
    it { is_expected.to validate_presence_of(:body_html) }
    it { is_expected.to validate_uniqueness_of(:email_type) }
    it { is_expected.to validate_inclusion_of(:email_type).in_array(Solicitation::GENERIC_EMAILS_TYPES.flatten.without(:bad_quality).map(&:to_s)) }
  end
end

require 'rails_helper'

RSpec.describe SolicitationMailTemplate do
  describe 'validations' do
    subject { build(:solicitation_mail_template) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body_html) }

    it 'validates presence of email_type when it cannot be generated' do
      template = build(:solicitation_mail_template, title: nil, email_type: nil)
      expect(template).not_to be_valid
      expect(template.errors[:email_type]).to include("doit être rempli(e)")
    end

    it 'validates uniqueness of title' do
      create(:solicitation_mail_template, title: 'Titre Unique')
      duplicate = build(:solicitation_mail_template, title: 'Titre Unique')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:title]).to include("n’est pas disponible")
    end

    it 'validates uniqueness of email_type' do
      create(:solicitation_mail_template, title: 'Existing One', email_type: 'existing_type')
      duplicate = build(:solicitation_mail_template, title: 'Other One', email_type: 'existing_type')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email_type]).to include("n’est pas disponible")
    end

    it 'does not allow email_type to be bad_quality' do
      template = build(:solicitation_mail_template, title: 'Bad Quality Label', email_type: 'bad_quality')
      expect(template).not_to be_valid
      expect(template.errors[:email_type]).to include("ne peut pas être 'bad_quality' car ce type d'email est réservé au système.")
    end

    it 'slugifies the email_type from title before validation' do
      template = build(:solicitation_mail_template, title: "Mon Super E-mail !", email_type: nil)
      template.valid?
      expect(template.email_type).to eq('mon_super_e_mail')
    end
  end
end

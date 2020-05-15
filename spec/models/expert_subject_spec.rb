require 'rails_helper'

RSpec.describe ExpertSubject, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :expert
      is_expected.to belong_to :institution_subject
    end
  end

  describe 'scopes' do
    describe 'relevant_for' do
      subject{ described_class.relevant_for(need) }

      let(:need) { create :need }
      let!(:expert_subject) do
        create :expert_subject,
               institution_subject: create(:institution_subject, subject: the_subject),
               expert: create(:expert, communes: communes)
      end

      context 'when the expert isn’t on the commune' do
        let(:the_subject) { need.subject }
        let(:communes) { [create(:commune)] }

        it{ is_expected.to be_blank }
      end

      context 'when the institution doesn’t handle that subject' do
        let(:the_subject) { create :subject }
        let(:communes) { [need.facility.commune] }

        it{ is_expected.to be_blank }
      end

      context 'when both subject and institution match' do
        let(:the_subject) { need.subject }
        let(:communes) { [need.facility.commune] }

        it{ is_expected.to eq [expert_subject] }
      end
    end
  end
end

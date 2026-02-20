require 'rails_helper'

RSpec.describe Manager::NeedsController do
  login_manager

  let(:antenne) { current_user.antenne }

  describe 'filters' do
    let!(:theme1) { create :theme, label: 'Theme 1' }
    let!(:theme2) { create :theme, label: 'Theme 2' }
    let!(:subject1) { create :subject, theme: theme1, label: 'Subject 1' }
    let!(:subject2) { create :subject, theme: theme2, label: 'Subject 2' }

    let!(:expert) { antenne.experts.first }
    let!(:institution_subject1) { create :institution_subject, institution: expert.antenne.institution, subject: subject1 }
    let!(:institution_subject2) { create :institution_subject, institution: expert.antenne.institution, subject: subject2 }
    let!(:need1) { create :need, subject: subject1 }
    let!(:need2) { create :need, subject: subject2 }

    let!(:expert_subject1) { expert.experts_subjects.create(institution_subject: institution_subject1) }
    let!(:expert_subject2) { expert.experts_subjects.create(institution_subject: institution_subject2) }
    let!(:match1) { create :match, expert: expert, need: need1, status: :quo }
    let!(:match2) { create :match, expert: expert, need: need2, status: :quo }

    describe 'filter keys override' do
      it 'includes all manager-specific filter keys' do
        expect(controller.send(:all_filter_keys)).to eq([:antennes, :themes, :subjects, :cooperations])
      end

      it 'includes dynamic filter keys' do
        expect(controller.send(:dynamic_filter_keys)).to eq([:subjects])
      end
    end
  end
end

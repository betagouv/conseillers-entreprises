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

    describe 'GET #quo_active with filters' do
      subject(:request) { get :quo_active }

      before { request }

      it 'includes available themes' do
        theme_labels = assigns(:filters)[:themes].map(&:label)
        subject_labels = assigns(:filters)[:subjects].map(&:label)

        expect(theme_labels).to include('Theme 1', 'Theme 2')
        expect(subject_labels).to include('Subject 1', 'Subject 2')
      end
    end

    describe 'GET #load_filter_options' do
      subject(:request) { get :load_filter_options }

      before { request }

      it 'returns subjects' do
        json_response = response.parsed_body

        expect(json_response).to have_key('subjects')
      end

      context 'with theme_id parameter' do
        subject(:request) { get :load_filter_options, params: { theme_id: theme1.id } }

        it 'filters subjects by theme' do
          subject_labels = response.parsed_body['subjects'].pluck('label')

          expect(subject_labels).to include('Subject 1')
          expect(subject_labels).not_to include('Subject 2')
        end
      end
    end

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

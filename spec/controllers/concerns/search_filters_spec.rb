require 'rails_helper'

RSpec.describe SearchFilters do
  controller(ApplicationController) do
    include SearchFilters

    def index
      initialize_filters(all_filter_keys)
      head :ok
    end

    def load_filter_options
      super
    end

    def base_needs_for_filters
      Need.all
    end
  end

  login_user

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'load_filter_options' => 'anonymous#load_filter_options'
    end
  end

  describe '#initialize_filters' do
    let!(:theme1) { create :theme, label: 'Alpha Theme' }
    let!(:theme2) { create :theme, label: 'Beta Theme' }
    let!(:subject1) { create :subject, theme: theme1, label: 'Subject Alpha' }
    let!(:subject2) { create :subject, theme: theme2, label: 'Subject Beta' }
    let!(:need1) { create :need, subject: subject1 }
    let!(:need2) { create :need, subject: subject2 }

    subject(:request) { get :index }

    before { request }

    it 'initializes filters with themes and subjects' do
      expect(assigns(:filters)[:themes].map(&:label)).to eq(['Alpha Theme', 'Beta Theme'])
      expect(assigns(:filters)[:subjects].map(&:label)).to eq(['Subject Alpha', 'Subject Beta'])
    end

    context 'with archived subjects' do
      let!(:archived_subject) { create :subject, theme: theme1, archived_at: Time.zone.now }
      let!(:need_archived) { create :need, subject: archived_subject }

      it 'filters out archived subjects' do
        expect(assigns(:filters)[:subjects].map(&:label)).not_to include(archived_subject.label)
      end
    end
  end

  describe '#base_themes' do
    subject(:request) { get :index }

    context 'filtering' do
      let!(:theme_with_need) { create :theme, label: 'Active Theme' }
      let!(:theme_without_need) { create :theme, label: 'Inactive Theme' }
      let!(:subject_active) { create :subject, theme: theme_with_need }
      let!(:need) { create :need, subject: subject_active }

      before { request }

      it 'only returns themes that have needs' do
        theme_labels = assigns(:filters)[:themes].map(&:label)

        expect(theme_labels).to include('Active Theme')
        expect(theme_labels).not_to include('Inactive Theme')
      end
    end

    context 'with archived subjects' do
      let!(:theme_with_archived) { create :theme, label: 'Inactive Theme' }
      let!(:archived_subject) { create :subject, theme: theme_with_archived, archived_at: Time.zone.now }
      let!(:need_archived) { create :need, subject: archived_subject }

      before { request }

      it 'excludes themes with only archived subjects' do
        expect(assigns(:filters)[:themes].map(&:label)).not_to include('Inactive Theme')
      end
    end

    context 'ordering' do
      let!(:theme_z) { create :theme, label: 'Zulu Theme' }
      let!(:theme_a) { create :theme, label: 'Alpha Theme' }
      let!(:theme_m) { create :theme, label: 'Mid Theme' }
      let!(:subject_z) { create :subject, theme: theme_z }
      let!(:subject_a) { create :subject, theme: theme_a }
      let!(:subject_m) { create :subject, theme: theme_m }
      let!(:need_z) { create :need, subject: subject_z }
      let!(:need_a) { create :need, subject: subject_a }
      let!(:need_m) { create :need, subject: subject_m }

      before { request }

      it 'returns themes sorted by label' do
        theme_labels = assigns(:filters)[:themes].map(&:label)

        expect(theme_labels).to eq(['Alpha Theme', 'Mid Theme', 'Zulu Theme'])
      end
    end
  end

  describe '#base_subjects' do
    let!(:theme1) { create :theme }
    let!(:theme2) { create :theme }
    let!(:subject1) { create :subject, theme: theme1, label: 'Subject 1' }
    let!(:subject2) { create :subject, theme: theme1, label: 'Subject 2' }
    let!(:subject3) { create :subject, theme: theme2, label: 'Subject 3' }
    let!(:need1) { create :need, subject: subject1 }
    let!(:need2) { create :need, subject: subject2 }
    let!(:need3) { create :need, subject: subject3 }

    context 'without theme_id parameter' do
      subject(:request) { get :index }

      before { request }

      it 'returns all subjects from themes with needs' do
        subject_labels = assigns(:filters)[:subjects].map(&:label)

        expect(subject_labels).to include('Subject 1', 'Subject 2', 'Subject 3')
      end
    end

    context 'with valid theme_id parameter' do
      subject(:request) { get :index, params: { theme_id: theme1.id } }

      before { request }

      it 'filters subjects by theme' do
        subject_labels = assigns(:filters)[:subjects].map(&:label)

        expect(subject_labels).to include('Subject 1', 'Subject 2')
        expect(subject_labels).not_to include('Subject 3')
      end
    end

    context 'with invalid theme_id parameter' do
      let!(:invalid_theme) { create :theme }

      subject(:request) { get :index, params: { theme_id: invalid_theme.id } }

      before { request }

      it 'ignores invalid theme_id' do
        subject_labels = assigns(:filters)[:subjects].map(&:label)

        # Should return all subjects since the theme_id is not in base_themes
        expect(subject_labels).to include('Subject 1', 'Subject 2', 'Subject 3')
      end
    end

    context 'with non-numeric theme_id' do
      subject(:request) { get :index, params: { theme_id: 'invalid' } }

      it 'safely handles non-numeric theme_id' do
        request

        expect(response).to be_successful
        expect(assigns(:filters)[:subjects].size).to eq(3)
      end
    end

    context 'with archived subjects' do
      let!(:archived_subject) { create :subject, theme: theme1, archived_at: Time.zone.now }
      let!(:need_archived) { create :need, subject: archived_subject }

      subject(:request) { get :index }

      before { request }

      it 'excludes archived subjects' do
        subject_labels = assigns(:filters)[:subjects].map(&:label)

        expect(subject_labels).not_to include(archived_subject.label)
      end
    end

    context 'ordering' do
      let!(:subject_z) { create :subject, theme: theme1, label: 'Zulu Subject' }
      let!(:subject_a) { create :subject, theme: theme1, label: 'Alpha Subject' }
      let!(:need_z) { create :need, subject: subject_z }
      let!(:need_a) { create :need, subject: subject_a }

      subject(:request) { get :index, params: { theme_id: theme1.id } }

      before { request }

      it 'returns subjects ordered by label' do
        subject_labels = assigns(:filters)[:subjects].map(&:label)

        expect(subject_labels.first).to eq('Alpha Subject')
        expect(subject_labels).to include('Subject 1', 'Subject 2', 'Zulu Subject')
      end
    end
  end

  describe '#load_filter_options' do
    let!(:theme) { create :theme }
    let!(:subject1) { create :subject, theme: theme, label: 'Subject 1' }
    let!(:subject2) { create :subject, theme: theme, label: 'Subject 2' }
    let!(:need1) { create :need, subject: subject1 }
    let!(:need2) { create :need, subject: subject2 }

    subject(:request) { get :load_filter_options }

    before { request }

    it 'returns dynamic filters as JSON' do
      expect(response).to be_successful
      expect(response.content_type).to include('application/json')
    end

    it 'returns subjects in JSON' do
      json_response = response.parsed_body

      expect(json_response).to have_key('subjects')
    end

    context 'with theme_id parameter' do
      let!(:theme2) { create :theme }
      let!(:subject3) { create :subject, theme: theme2 }
      let!(:need3) { create :need, subject: subject3 }

      subject(:request) { get :load_filter_options, params: { theme_id: theme.id } }

      it 'returns filtered subjects' do
        json_response = response.parsed_body
        subject_labels = json_response['subjects'].pluck('label')

        expect(subject_labels).to include('Subject 1', 'Subject 2')
        expect(subject_labels).not_to include(subject3.label)
      end
    end
  end

  describe 'default implementations' do
    it 'returns default all_filter_keys' do
      expect(controller.send(:all_filter_keys)).to eq([:themes, :subjects])
    end

    it 'returns default dynamic_filter_keys' do
      expect(controller.send(:dynamic_filter_keys)).to eq([:subjects])
    end
  end
end

require 'rails_helper'

RSpec.describe Stats::TeamController do
  login_admin

  describe 'GET #matches' do
    before do
      # Mock footer_landing to avoid SharedController errors
      allow(controller).to receive(:fetch_themes).and_return(nil)
    end

    let(:institution) { create :institution }
    let(:antenne) { create :antenne, institution: institution }
    let(:subject_model) { create :subject }
    let(:solicitation) { create :solicitation }
    let(:diagnosis) { create :diagnosis_completed, solicitation: solicitation }

    context 'without external cooperation needs' do

      it 'includes aggregated themes and subjects charts' do
        get :matches, params: { start_date: 2.months.ago, end_date: Date.today }

        expect(assigns(:charts_names)).to include('needs_themes_all')
        expect(assigns(:charts_names)).to include('needs_subjects_all')
        expect(assigns(:charts_names)).not_to include('needs_themes_from_external_cooperation')
        expect(assigns(:charts_names)).not_to include('needs_subjects_from_external_cooperation')
      end
    end

    context 'with external cooperation needs' do
      let(:cooperation) { create :cooperation, institution: institution, external: true }
      let(:solicitation_with_coop) { create :solicitation, cooperation: cooperation }
      let(:diagnosis_with_cooperation) { create :diagnosis_completed, solicitation: solicitation_with_coop }

      before do
        # Update need created_at to be within the date range
        diagnosis_with_cooperation.needs.first.update_columns(created_at: 1.month.ago)
      end

      it 'includes separated themes and subjects charts for external and non-external cooperation' do
        get :matches, params: { start_date: 2.months.ago, end_date: Date.today }

        expect(assigns(:charts_names)).to include('needs_themes_not_from_external_cooperation')
        expect(assigns(:charts_names)).to include('needs_themes_from_external_cooperation')
        expect(assigns(:charts_names)).to include('needs_subjects_not_from_external_cooperation')
        expect(assigns(:charts_names)).to include('needs_subjects_from_external_cooperation')
        expect(assigns(:charts_names)).not_to include('needs_themes_all')
        expect(assigns(:charts_names)).not_to include('needs_subjects_all')
      end
    end

    context 'respects date filter when checking for external cooperation' do
      let(:cooperation) { create :cooperation, institution: institution, external: true }
      let(:solicitation_with_coop) { create :solicitation, cooperation: cooperation }
      let(:diagnosis_with_cooperation) { create :diagnosis_completed, solicitation: solicitation_with_coop }

      before do
        # Update needs created_at to be within the date range
        diagnosis_with_cooperation.needs.first.update_columns(created_at: 1.month.ago)
        # Create an old need outside the date range
        old_solicitation = create :solicitation, cooperation: cooperation
        old_diagnosis = create :diagnosis_completed, solicitation: old_solicitation
        old_diagnosis.needs.first.update_columns(created_at: 6.months.ago)
      end

      it 'shows separated charts when external cooperation exists in date range' do
        get :matches, params: {
          start_date: 2.months.ago,
          end_date: Date.today
        }

        # Should find the recent need with external cooperation, not the old one
        expect(assigns(:charts_names)).to include('needs_themes_from_external_cooperation')
      end
    end
  end

  describe '#themes_subjects_charts' do
    let(:controller_instance) { described_class.new }

    before do
      allow(controller_instance).to receive(:stats_params).and_return({})
    end

    context 'when has_external_cooperation is true' do
      it 'returns separated charts for external and non-external cooperation' do
        controller_instance.instance_variable_set(:@stats_params, { has_external_cooperation: true })

        result = controller_instance.send(:themes_subjects_charts)

        expect(result).to eq(%w[
          needs_themes_not_from_external_cooperation
          needs_themes_from_external_cooperation
          needs_subjects_not_from_external_cooperation
          needs_subjects_from_external_cooperation
        ])
      end
    end

    context 'when has_external_cooperation is false' do
      it 'returns aggregated charts' do
        controller_instance.instance_variable_set(:@stats_params, { has_external_cooperation: false })

        result = controller_instance.send(:themes_subjects_charts)

        expect(result).to eq(%w[needs_themes_all needs_subjects_all])
      end
    end
  end

  describe '#base_needs_for_filters' do
    let(:controller_instance) { described_class.new }
    let(:solicitation) { create :solicitation }
    let(:diagnosis) { create :diagnosis_completed, solicitation: solicitation }

    before do
      diagnosis.needs.first.update_columns(created_at: 1.month.ago)
      controller_instance.instance_variable_set(:@stats_params, {
        start_date: 2.months.ago,
        end_date: Date.today
      })
    end

    it 'returns a filtered scope of needs' do
      result = controller_instance.send(:base_needs_for_filters)

      expect(result).to be_a(ActiveRecord::Relation)
      expect(result.model).to eq(Need)
    end

    it 'filters by date range' do
      old_solicitation = create :solicitation
      old_diagnosis = create :diagnosis_completed, solicitation: old_solicitation
      old_diagnosis.needs.first.update_columns(created_at: 6.months.ago)

      result = controller_instance.send(:base_needs_for_filters)

      expect(result).not_to include(old_diagnosis.needs.first)
      expect(result).to include(diagnosis.needs.first)
    end

    it 'memoizes the result' do
      first_call = controller_instance.send(:base_needs_for_filters)
      second_call = controller_instance.send(:base_needs_for_filters)

      expect(first_call.object_id).to eq(second_call.object_id)
    end
  end

  describe '#set_stats_params' do
    let(:controller_instance) { described_class.new }
    let(:solicitation) { create :solicitation }
    let(:diagnosis) { create :diagnosis_completed, solicitation: solicitation }
    let(:subject_model) { create :subject }

    before do
      diagnosis.needs.first.update_columns(created_at: 1.month.ago)
      allow(controller_instance).to receive_messages(stats_params: {
        start_date: 2.months.ago,
        end_date: Date.today
      }, session: {})
    end

    it 'sets has_external_cooperation to false when no external cooperation exists' do
      controller_instance.send(:set_stats_params)

      expect(controller_instance.instance_variable_get(:@stats_params)[:has_external_cooperation]).to be false
    end

    it 'sets has_external_cooperation to true when external cooperation exists' do
      cooperation = create :cooperation, external: true
      solicitation_with_coop = create :solicitation, cooperation: cooperation
      diagnosis_with_coop = create :diagnosis_completed, solicitation: solicitation_with_coop
      diagnosis_with_coop.needs.first.update_columns(created_at: 1.month.ago)

      controller_instance.send(:set_stats_params)

      expect(controller_instance.instance_variable_get(:@stats_params)[:has_external_cooperation]).to be true
    end

    it 'stores params in session' do
      session = {}
      allow(controller_instance).to receive(:session).and_return(session)

      controller_instance.send(:set_stats_params)

      expect(session[:team_stats_params]).not_to be_nil
    end
  end
end

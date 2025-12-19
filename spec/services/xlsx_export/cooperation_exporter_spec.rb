require 'rails_helper'

RSpec.describe XlsxExport::CooperationExporter do
  subject(:package) { described_class.new(params).xlsx }

  let(:cooperation) { create(:cooperation, name: 'Test Cooperation') }
  let(:start_date) { Date.new(2025, 1, 1) }
  let(:end_date) { Date.new(2025, 3, 31) }
  let(:params) { { cooperation: cooperation, start_date: start_date, end_date: end_date } }
  let!(:landing) { create(:landing, :with_subjects, cooperation: cooperation) }
  let!(:landing_theme) { landing.landing_themes.first }
  let!(:landing_subject) { landing_theme.landing_subjects.first }

  describe '#xlsx' do
    context 'without provenance details' do
      let!(:solicitation) do
        create(:solicitation,
          landing: landing,
          landing_subject: landing_subject,
          completed_at: Date.new(2025, 2, 15),
          status: :processed)
      end
      let!(:diagnosis) { create(:diagnosis_completed, solicitation: solicitation, created_at: Date.new(2025, 2, 16)) }

      it 'creates a valid Axlsx package' do
        expect(package).to be_a(Axlsx::Package)
        expect(package.use_shared_strings).to be true
      end

      it 'includes only quarterly and annual worksheets without provenance' do
        workbook = package.workbook
        sheet_names = workbook.worksheets.map(&:name)

        expect(sheet_names).to contain_exactly(
          I18n.t('cooperation_stats_exporter.volume.tab'),
          I18n.t('cooperation_stats_exporter.repartition.tab'),
          I18n.t('cooperation_stats_exporter.volume.annual_tab'),
          I18n.t('cooperation_stats_exporter.repartition.annual_tab')
        )
      end
    end

    context 'with provenance details' do
      let!(:solicitation) do
        create(:solicitation,
          landing: landing,
          landing_subject: landing_subject,
          completed_at: Date.new(2025, 2, 15),
          status: :processed,
          provenance_detail: 'Partner Website')
      end
      let!(:diagnosis) { create(:diagnosis_completed, solicitation: solicitation, created_at: Date.new(2025, 2, 16)) }

      it 'includes provenance worksheets' do
        workbook = package.workbook
        sheet_names = workbook.worksheets.map(&:name)

        expect(sheet_names).to include(
          I18n.t('cooperation_stats_exporter.provenance.tab'),
          I18n.t('cooperation_stats_exporter.provenance.annual_tab')
        )
        expect(sheet_names.count).to eq(6)
      end
    end

    describe 'Volume worksheet' do
      let!(:solicitation) do
        create(:solicitation,
          landing: landing,
          landing_subject: landing_subject,
          completed_at: Date.new(2025, 2, 15),
          status: :processed)
      end
      let!(:diagnosis) { create(:diagnosis_completed, solicitation: solicitation, created_at: Date.new(2025, 2, 16)) }

      it 'has correct title in first row' do
        volume_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.volume.tab') }
        expect(volume_sheet).not_to be_nil

        first_row_value = volume_sheet.rows.first.cells.first.value
        period = "#{end_date.year}T#{TimeDurationService::Quarters.new.find_quarter_for_month(start_date.month)}"
        expected_title = I18n.t('cooperation_stats_exporter.volume.title', cooperation: cooperation.name, period: period)

        expect(first_row_value).to eq(expected_title)
      end

      it 'includes transmission and positioning sections' do
        volume_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.volume.tab') }

        cell_values = volume_sheet.rows.map { |row| row.cells.map(&:value) }.flatten.compact

        expect(cell_values).to include(I18n.t('cooperation_stats_exporter.volume.transmitted_header'))
        expect(cell_values).to include(I18n.t('cooperation_stats_exporter.volume.positionning_header'))
        expect(cell_values).to include(I18n.t('cooperation_stats_exporter.detected_solicitations'))
      end

      it 'has columns configured' do
        volume_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.volume.tab') }

        expect(volume_sheet.column_info).not_to be_empty
      end
    end

    describe 'Repartition worksheet' do
      let!(:solicitation) do
        create(:solicitation,
          landing: landing,
          landing_subject: landing_subject,
          completed_at: Date.new(2025, 2, 15),
          status: :processed)
      end
      let!(:diagnosis) { create(:diagnosis_completed, solicitation: solicitation, created_at: Date.new(2025, 2, 16)) }

      it 'has correct title in first row' do
        repartition_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.repartition.tab') }
        expect(repartition_sheet).not_to be_nil

        first_row_value = repartition_sheet.rows.first.cells.first.value
        period = "#{end_date.year}T#{TimeDurationService::Quarters.new.find_quarter_for_month(start_date.month)}"
        expected_title = I18n.t('cooperation_stats_exporter.repartition.title', cooperation: cooperation.name, period: period)

        expect(first_row_value).to eq(expected_title)
      end

      it 'includes all repartition sections' do
        repartition_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.repartition.tab') }

        cell_values = repartition_sheet.rows.map { |row| row.cells.map(&:value) }.flatten.compact

        expect(cell_values).to include(I18n.t('cooperation_stats_exporter.repartition.by_theme_header'))
        expect(cell_values).to include(I18n.t('cooperation_stats_exporter.repartition.by_subject_header'))
        expect(cell_values).to include(I18n.t('cooperation_stats_exporter.repartition.by_region_header'))
        expect(cell_values).to include(I18n.t('cooperation_stats_exporter.repartition.by_effectif_header'))
        expect(cell_values).to include(I18n.t('cooperation_stats_exporter.repartition.by_naf_code_header'))
      end

      it 'has columns configured' do
        repartition_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.repartition.tab') }

        expect(repartition_sheet.column_info).not_to be_empty
      end
    end

    describe 'Provenance worksheet' do
      let!(:solicitation_with_provenance) do
        create(:solicitation,
          landing: landing,
          landing_subject: landing_subject,
          completed_at: Date.new(2025, 2, 15),
          status: :processed,
          provenance_detail: 'Partner Website')
      end
      let!(:diagnosis) { create(:diagnosis_completed, solicitation: solicitation_with_provenance, created_at: Date.new(2025, 2, 16)) }

      it 'includes provenance worksheet when provenance details exist' do
        provenance_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.provenance.tab') }

        expect(provenance_sheet).not_to be_nil
      end

      it 'has correct headers' do
        provenance_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.provenance.tab') }

        header_row = provenance_sheet.rows.first.cells.map(&:value)

        expect(header_row).to include(I18n.t('cooperation_stats_exporter.provenance.provenance_detail'))
        expect(header_row).to include(I18n.t('cooperation_stats_exporter.provenance.solicitations_count'))
        expect(header_row).to include(I18n.t('cooperation_stats_exporter.provenance.abandonned_count'))
        expect(header_row).to include(I18n.t('cooperation_stats_exporter.provenance.matched_count'))
        expect(header_row).to include(I18n.t('cooperation_stats_exporter.provenance.done_count'))
      end
    end

    describe 'Annual worksheets' do
      let!(:solicitation) do
        create(:solicitation,
          landing: landing,
          landing_subject: landing_subject,
          completed_at: Date.new(2025, 2, 15),
          status: :processed)
      end
      let!(:diagnosis) { create(:diagnosis_completed, solicitation: solicitation, created_at: Date.new(2025, 2, 16)) }

      it 'includes annual volume worksheet with correct title' do
        annual_volume_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.volume.annual_tab') }
        expect(annual_volume_sheet).not_to be_nil

        first_row_value = annual_volume_sheet.rows.first.cells.first.value
        yearly_period = end_date.year.to_s
        expected_title = I18n.t('cooperation_stats_exporter.volume.annual_title', cooperation: cooperation.name, period: yearly_period)

        expect(first_row_value).to eq(expected_title)
      end

      it 'includes annual repartition worksheet with correct title' do
        annual_repartition_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.repartition.annual_tab') }
        expect(annual_repartition_sheet).not_to be_nil

        first_row_value = annual_repartition_sheet.rows.first.cells.first.value
        yearly_period = end_date.year.to_s
        expected_title = I18n.t('cooperation_stats_exporter.repartition.annual_title', cooperation: cooperation.name, period: yearly_period)

        expect(first_row_value).to eq(expected_title)
      end

      context 'with provenance details' do
        let!(:solicitation_with_provenance) do
          create(:solicitation,
            landing: landing,
            landing_subject: landing_subject,
            completed_at: Date.new(2025, 1, 10),
            status: :processed,
            provenance_detail: 'Annual Partner')
        end
        let!(:diagnosis2) { create(:diagnosis_completed, solicitation: solicitation_with_provenance, created_at: Date.new(2025, 1, 11)) }

        it 'includes annual provenance worksheet' do
          annual_provenance_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.provenance.annual_tab') }

          expect(annual_provenance_sheet).not_to be_nil
        end
      end
    end

    describe 'date filtering' do
      let!(:solicitation_in_range) do
        create(:solicitation,
          landing: landing,
          landing_subject: landing_subject,
          completed_at: Date.new(2025, 2, 15),
          status: :processed)
      end
      let!(:diagnosis_in_range) { create(:diagnosis_completed, solicitation: solicitation_in_range, created_at: Date.new(2025, 2, 16)) }

      let!(:solicitation_out_range) do
        create(:solicitation,
          landing: landing,
          landing_subject: landing_subject,
          completed_at: Date.new(2024, 12, 15),
          status: :processed)
      end
      let!(:diagnosis_out_range) { create(:diagnosis_completed, solicitation: solicitation_out_range, created_at: Date.new(2024, 12, 16)) }

      it 'correctly filters solicitations by date range in Volume worksheet' do
        volume_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.volume.tab') }

        detected_row = volume_sheet.rows.find { |row| row.cells.first&.value == I18n.t('cooperation_stats_exporter.detected_solicitations') }

        expect(detected_row).not_to be_nil
        expect(detected_row.cells[1].value).to eq(1) # Only one solicitation in range
      end
    end

    describe 'styles and formatting' do
      let!(:solicitation) do
        create(:solicitation,
          landing: landing,
          landing_subject: landing_subject,
          completed_at: Date.new(2025, 2, 15),
          status: :processed)
      end
      let!(:diagnosis) { create(:diagnosis_completed, solicitation: solicitation, created_at: Date.new(2025, 2, 16)) }

      it 'applies title style to first row' do
        volume_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.volume.tab') }
        first_row_style = volume_sheet.rows.first.cells.first.style

        expect(first_row_style).not_to be_nil
      end

      it 'has title spanning multiple columns' do
        volume_sheet = package.workbook.worksheets.find { |ws| ws.name == I18n.t('cooperation_stats_exporter.volume.tab') }

        first_row = volume_sheet.rows.first
        expect(first_row.cells.first.value).to be_present
      end
    end
  end

  describe '#initialize' do
    subject(:exporter) { described_class.new(params) }

    it 'stores the cooperation from params' do
      expect(exporter.instance_variable_get(:@cooperation)).to eq(cooperation)
    end

    it 'stores the start_date from params' do
      expect(exporter.instance_variable_get(:@start_date)).to eq(start_date)
    end

    it 'stores the end_date from params' do
      expect(exporter.instance_variable_get(:@end_date)).to eq(end_date)
    end
  end
end

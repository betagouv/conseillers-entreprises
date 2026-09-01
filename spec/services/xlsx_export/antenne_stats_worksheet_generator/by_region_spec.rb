require 'rails_helper'

RSpec.describe XlsxExport::AntenneStatsWorksheetGenerator::ByRegion do
  subject(:generate) { described_class.new(sheet, national_antenne, needs, styles).generate }

  let(:package) { Axlsx::Package.new }
  let(:sheet) { package.workbook.add_worksheet }
  let(:styles) { package.workbook.styles }

  let(:institution) { create(:institution) }
  let(:national_antenne) { create(:antenne, :national, institution: institution) }
  let(:expert) { create(:expert, antenne: create(:antenne, :local, institution: institution)) }

  # Deux besoins pris en charge (échange effectif) : un dans les 5 jours, un au-delà → taux attendu 50 %
  let!(:need_in_five_days) do
    create(:need).tap do |need|
      create(:match, need: need, expert: expert, status: :done,
                     sent_at: 10.days.ago, taken_care_of_at: 8.days.ago)
    end
  end
  let!(:need_after_five_days) do
    create(:need).tap do |need|
      create(:match, need: need, expert: expert, status: :done,
                     sent_at: 10.days.ago, taken_care_of_at: 2.days.ago)
    end
  end

  let(:needs) { Need.where(id: [need_in_five_days.id, need_after_five_days.id]) }

  let(:header_row) { sheet.rows.find { |row| row.cells.first&.value == I18n.t('antenne_stats_exporter.region') } }
  let(:national_row) do
    sheet.rows.find { |row| row.cells.first&.value == I18n.t('antenne_stats_exporter.national') }
  end

  before { generate }

  it 'adds the five-day exchange rate as the seventh header column' do
    values = header_row.cells.map(&:value)

    expect(values.size).to eq 7
    expect(values.last).to eq I18n.t('antenne_stats_exporter.taken_care_in_five_days_rate')
  end

  it 'computes the five-day exchange rate on the national reference row' do
    values = national_row.cells.map(&:value)

    expect(values.size).to eq 7
    expect(values.last).to eq 0.5
  end
end

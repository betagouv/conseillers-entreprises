require 'rails_helper'

RSpec.describe XlsxExport::AntenneStatsWorksheetGenerator::ByPosition do
  subject(:generate) { described_class.new(sheet, antenne, needs, 1.week.ago.to_date, Date.today, :quarter, styles).generate }

  let(:package) { Axlsx::Package.new }
  let(:sheet) { package.workbook.add_worksheet }
  let(:styles) { package.workbook.styles }

  let(:antenne) { create(:antenne, :local) }
  let(:expert) { create(:expert, antenne: antenne) }
  let(:sent_at) { 3.months.ago }

  # Trimestre précédent : deux échanges (un en 1 jour, un en 10 jours) et deux refus
  # → taux attendu 50 % des échanges, et non 25 % de toutes les mises en relation
  let!(:matches) do
    [
      create(:match, need: create(:need, created_at: sent_at), expert: expert, status: :done,
                     sent_at: sent_at, taken_care_of_at: sent_at + 1.day),
      create(:match, need: create(:need, created_at: sent_at), expert: expert, status: :done_no_help,
                     sent_at: sent_at, taken_care_of_at: sent_at + 10.days),
      create(:match, need: create(:need, created_at: sent_at), expert: expert, status: :not_for_me, sent_at: sent_at),
      create(:match, need: create(:need, created_at: sent_at), expert: expert, status: :not_for_me, sent_at: sent_at)
    ]
  end

  let(:needs) { Need.where(id: matches.map(&:need_id)) }

  let(:three_days_row) do
    sheet.rows.find { |row| row.cells.first&.value == "#{I18n.t('antenne_stats_exporter.funnel.taken_care_in_three_days')} **" }
  end
  let(:five_days_row) do
    sheet.rows.find { |row| row.cells.first&.value == "#{I18n.t('antenne_stats_exporter.funnel.taken_care_in_five_days')} **" }
  end

  before { generate }

  it 'computes the previous quarter three-day rate on matches with exchange' do
    values = three_days_row.cells.map(&:value)

    expect(values.last).to eq 0.5
  end

  it 'computes the previous quarter five-day rate on matches with exchange' do
    values = five_days_row.cells.map(&:value)

    expect(values.last).to eq 0.5
  end
end

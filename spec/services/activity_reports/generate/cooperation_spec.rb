# frozen_string_literal: true

require 'rails_helper'
describe ActivityReports::Generate::Cooperation do

  describe 'generate_files' do
    let(:cooperation) { create :cooperation }
    let!(:a_need) { create :need, created_at: 3.months.ago, solicitation: create(:solicitation, cooperation: cooperation) }
    let(:quarters) { described_class.new(cooperation).send(:last_periods) }
    let(:generate_files) { described_class.new(cooperation).send(:generate_files, quarters.first) }

    it 'create activity_report' do
      expect { generate_files }.to change(ActivityReport, :count).by(1)
      expect(ActivityReport.last.category).to eq('cooperation')
    end
  end

  describe 'destroy_old_files' do
    let(:cooperation) { create :cooperation }
    let!(:a_need) { create :need, created_at: 6.months.ago, solicitation: create(:solicitation, cooperation: cooperation) }
    let!(:activity_report_ok) { create :activity_report, :category_cooperation, reportable: cooperation, start_date: 18.months.ago }
    let!(:activity_report_ko) { create :activity_report, :category_cooperation, reportable: cooperation, start_date: 3.years.ago }
    let!(:quarters) { described_class.new(cooperation).send(:last_periods) }
    let(:destroy_old_report) { described_class.new(cooperation).send(:destroy_old_files, quarters) }

    before do
      activity_report_ok.update(start_date: quarters.first.first)
    end

    it 'delete activity_report with date outside of quarters' do
      expect { destroy_old_report }.to change(ActivityReport, :count).by(-1)
      expect(activity_report_ok.reload).not_to be_nil
    end
  end
end

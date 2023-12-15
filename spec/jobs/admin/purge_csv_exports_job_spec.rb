require 'rails_helper'
RSpec.describe Admin::PurgeCsvExportsJob do
  describe 'enqueue a job' do
    it { assert_enqueued_jobs(1) { described_class.perform_later } }
  end

  describe 'purge' do
    let(:user) { create :user, :admin }
    let(:solicitation_01) { create :solicitation }
    let(:result) { Solicitation.all.export_csv }
    let(:file) { result.build_file }

    context 'recent export' do
      before do
        travel_to(2.days.ago) do
          user.csv_exports.attach(io: File.open(file.path),
                                  key: "csv_exports/#{user.full_name.parameterize}/#{result.filename}",
                                  filename: result.filename,
                                  content_type: 'application/csv')
        end
        travel_back
      end

      it 'delete quarterly_report with date outside of quarters' do
        expect { described_class.perform_now }.not_to change(user.csv_exports, :count)
      end
    end

    context 'old export' do
      before do
        travel_to(2.weeks.ago) do
          user.csv_exports.attach(io: File.open(file.path),
                                  key: "csv_exports/#{user.full_name.parameterize}/#{result.filename}",
                                  filename: result.filename,
                                  content_type: 'application/csv')
        end
        travel_back
      end

      it 'delete quarterly_report with date outside of quarters' do
        expect { described_class.perform_now }.to change(user.csv_exports, :count).by(-1)
      end
    end
  end
end

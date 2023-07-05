# frozen_string_literal: true

require 'rails_helper'
describe CsvExport do
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

      it 'delete monthly_report with date outside of months' do
        expect { described_class.purge_later }.not_to change(user.csv_exports, :count)
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

      it 'delete monthly_report with date outside of months' do
        expect { described_class.purge_later }.to change(user.csv_exports, :count).by(-1)
      end
    end
  end
end

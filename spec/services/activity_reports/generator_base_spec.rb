require 'rails_helper'

describe ActivityReports::GeneratorBase do
  describe 'Enqueue' do
    before do
      # Build a minimal Generator/Generator::Enqueue class pair
      generator = Class.new(described_class)
      stub_const('Generator', generator)
      enqueue = Class.new(described_class::EnqueueBase) do
        def collection = %w[Some Objects]
      end
      generator.const_set(:Enqueue, enqueue)
    end

    it 'enqueues the jobs with the objects of the collection' do
      Generator::Enqueue.perform_now

      assert_enqueued_with(job: Generator, args: ['Some'])
      assert_enqueued_with(job: Generator, args: ['Objects'])
    end
  end

  describe 'primitives' do
    let(:generator_class) do # a minimal Generator class
      Class.new(described_class) do
        def report_type = :matches

        def reports_periods = (6..12).map{ Date.new(2000,it).all_month }
      end
    end
    let(:reports) { (3..9).map{ Date.new(2000,it).all_month }.map{ create(:activity_report, :category_matches, period: it) } }
    let(:needs) { (1..11).map{ Date.new(2000,it, 15) }.map{ double(created_at: it) } }
    let(:item) { double(perimeter_received_needs: needs, activity_reports: ActivityReport.where(id: reports.pluck(:id))) }
    let(:generator) { generator_class.new(item) }

    it 'returns the correct periods' do
      expect(generator.reports_periods_with_data).to eq (6..12).map{ Date.new(2000,it).all_month }
      expect(generator.existing_reports_periods).to eq (3..9).map{ Date.new(2000,it).all_month }
      expect(generator.missing_reports_periods).to eq (10..12).map{ Date.new(2000,it).all_month }
      expect(generator.expired_reports).to eq reports.first(3)
    end

    context 'last day of month' do
      let(:needs) { [double(created_at: Date.new(2000, 10, 31))] }

      it 'returns the correct periods' do
        expect(generator.reports_periods_with_data).to eq (10..12).map{ Date.new(2000,it).all_month }
      end
    end
  end
end

require 'rails_helper'

describe Stats::Concerns::PartitionedCategory, type: :model do
  # Minimal stand-in for Stats::BaseStats: PartitionedCategory#categorized_results
  # calls `super`, so the including class must provide the base pipeline's
  # private categorized_results(query) that PartitionedCategory overrides.
  let(:base_class) do
    Class.new do
      attr_accessor :category_buckets

      def call
        categorized_results(nil)
      end

      private

      # Shaped like the real Stats::BaseStats#categorized_results output:
      # { category => { month => count } }, one entry per category grouping.
      def categorized_results(_query)
        { 'a' => { '2026-01-01' => 2 }, nil => { '2026-01-01' => 3 } }
      end
    end
  end

  let(:graph_class) do
    Class.new(base_class) { include Stats::Concerns::PartitionedCategory }
  end

  subject(:graph) { graph_class.new }

  before { graph.category_buckets = category_buckets }

  context 'when an :else bucket is declared but a row is still uncategorized' do
    let(:category_buckets) { [[:a, 'some_condition'], [:b, :else]] }

    it 'logs a warning and still drops the NULL-category row' do
      allow(Rails.logger).to receive(:warn)

      results = graph.call

      expect(results).to eq({ 'a' => { '2026-01-01' => 2 } })
      expect(Rails.logger).to have_received(:warn).with(/3 row\(s\) matched no category/)
    end
  end

  context 'when no :else bucket is declared' do
    let(:category_buckets) { [[:a, 'some_condition']] }

    it 'drops the NULL-category row silently, as documented' do
      allow(Rails.logger).to receive(:warn)

      results = graph.call

      expect(results).to eq({ 'a' => { '2026-01-01' => 2 } })
      expect(Rails.logger).not_to have_received(:warn)
    end
  end
end

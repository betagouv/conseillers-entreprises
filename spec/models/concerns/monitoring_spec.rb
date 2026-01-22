require 'rails_helper'

RSpec.describe Monitoring do
  describe '#includes_match_status_rates' do
    before do
      expert = create(:expert)
      create_list(:match, 2, expert: expert, status: :quo, sent_at: Time.now)
      create_list(:match, 2, expert: expert, status: :not_for_me, sent_at: Time.now)
      create_list(:match, 1, expert: expert, status: :done, sent_at: Time.now)
      create_list(:match, 2, expert: expert, status: :quo, sent_at: 2.days.ago)
    end

    subject { Antenne.includes_match_status_rates(period: 1.day.ago..) }

    it do
      expect(subject.first.received_matches_count).to eq 5
      expect(subject.first.done_count).to eq 1
      expect(subject.first.not_for_me_count).to eq 2
      expect(subject.first.done_rate).to eq 0.2
      expect(subject.first.not_for_me_rate).to eq 0.4
    end
  end

  describe '#includes_satisfying_rate' do
    before do
      expert = create(:expert)
      create_list(:match, 2, expert: expert, status: :done, sent_at: Time.now) do |match|
        create(:company_satisfaction, need: match.need, contacted_by_expert: true, useful_exchange: false)
      end
      create_list(:match, 1, expert: expert, status: :done, sent_at: Time.now) do |match|
        create(:company_satisfaction, need: match.need, contacted_by_expert: false, useful_exchange: true)
      end
      create_list(:match, 1, expert: expert, status: :done, sent_at: Time.now) do |match|
        create(:company_satisfaction, need: match.need, contacted_by_expert: true, useful_exchange: true)
      end
      create_list(:match, 1, expert: expert, status: :done, sent_at: 2.days.ago) do |match| # ignored
        create(:company_satisfaction, need: match.need, contacted_by_expert: true, useful_exchange: true)
      end
    end

    subject { Antenne.includes_satisfying_rate(period: 1.day.ago..) }

    it do
      expect(subject.first.company_satisfactions_count).to eq 4
      expect(subject.first.contacted_by_expert_count).to eq 3
      expect(subject.first.useful_exchange_count).to eq 2
      expect(subject.first.satisfying_count).to eq 1
      expect(subject.first.satisfying_rate).to eq 0.25
    end
  end

  describe 'high-level scopes' do
    before do
      stub_const('Monitoring::MATCHES_COUNT', 2..)
      stub_const('Monitoring::MATCHES_NOT_FOR_ME_RATE', 0.5..)
      stub_const('Monitoring::MATCHES_PERIOD', 1.day.ago..)
      stub_const('Monitoring::SOLICITATIONS_PERIOD', 1.day.ago..)
      stub_const('Monitoring::MATCHES_DONE_RADE', ..0.5)
      stub_const('Monitoring::SOLICITATIONS_COUNT', 2..)
      stub_const('Monitoring::SOLICITATIONS_SATISFYING_RATE', ..0.5)
    end

    describe '#often_not_for_me' do
      before do
        create_list(:match, 2, expert: create(:expert, antenne: antenne_1), status: :quo, sent_at: Time.now)
        create_list(:match, 2, expert: create(:expert, antenne: antenne_2), status: :not_for_me, sent_at: Time.now)
      end

      let(:antenne_1) { create(:antenne) }
      let(:antenne_2) { create(:antenne) }

      subject { Antenne.often_not_for_me }

      it do
        expect(subject).to contain_exactly(antenne_2)
      end
    end

    describe '#rarely_done' do
      before do
        create_list(:match, 2, expert: create(:expert, antenne: antenne_1), status: :quo, sent_at: Time.now)
        create_list(:match, 2, expert: create(:expert, antenne: antenne_2), status: :done, sent_at: Time.now)
      end

      let(:antenne_1) { create(:antenne) }
      let(:antenne_2) { create(:antenne) }

      subject { Antenne.rarely_done }

      it do
        expect(subject).to contain_exactly(antenne_1)
      end
    end

    describe '#rarely_satisfying' do
      before do
        create_list(:match, 2, expert: create(:expert, antenne: antenne_1), status: :done, sent_at: Time.now) do |match|
          create(:company_satisfaction, need: match.need, contacted_by_expert: true, useful_exchange: true)
        end
        create_list(:match, 2, expert: create(:expert, antenne: antenne_2), status: :done, sent_at: Time.now) do |match|
          create(:company_satisfaction, need: match.need, contacted_by_expert: false, useful_exchange: false)
        end
      end

      let(:antenne_1) { create(:antenne) }
      let(:antenne_2) { create(:antenne) }

      subject { Antenne.rarely_satisfying }

      it do
        expect(subject).to contain_exactly(antenne_2)
      end
    end
  end
end

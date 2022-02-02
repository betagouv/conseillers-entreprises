# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe SolicitationMailer do
  describe '#bad_quality_difficulties' do
    subject(:mail) { described_class.bad_quality_difficulties(solicitation).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:to].value).to eq solicitation.email }
  end

  describe '#bad_quality_investment' do
    subject(:mail) { described_class.bad_quality_investment(solicitation).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:to].value).to eq solicitation.email }
  end

  describe '#employee_labor_law' do
    subject(:mail) { described_class.employee_labor_law(solicitation).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:to].value).to eq solicitation.email }
  end

  describe '#out_of_region' do
    subject(:mail) { described_class.out_of_region(solicitation).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:to].value).to eq solicitation.email }
  end

  describe '#moderation' do
    subject(:mail) { described_class.moderation(solicitation).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:to].value).to eq solicitation.email }
  end

  describe '#creation' do
    subject(:mail) { described_class.creation(solicitation).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:to].value).to eq solicitation.email }
  end

  describe '#siret' do
    subject(:mail) { described_class.siret(solicitation).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:to].value).to eq solicitation.email }
  end

  describe '#particular_retirement' do
    subject(:mail) { described_class.particular_retirement(solicitation).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:to].value).to eq solicitation.email }
  end
end

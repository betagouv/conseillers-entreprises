# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Institution do
  it do
    is_expected.to have_many :experts
    is_expected.to validate_presence_of :name
  end

  describe 'relations' do
    describe 'antenne' do
      let(:active_antenne) { create :antenne }
      let(:deleted_antenne) { create :antenne, deleted_at: Time.now }
      let(:institution) { create :institution, antennes: [active_antenne, deleted_antenne] }

      subject { institution.antennes }

      before { institution.reload }

      it 'return only not deleted antennes' do
        is_expected.to match [active_antenne]
      end
    end
  end

  describe 'callbacks' do
    context 'update_referencement_coverages' do
      let(:institution) { create :institution }
      let(:antenne) { create :antenne, institution: institution }

      context 'add institution_subject' do
        it 'calls update_referencement_coverages' do
          allow(antenne).to receive(:update_referencement_coverages)
          institution.institutions_subjects.create(subject: create(:subject))
          expect(antenne).to have_received(:update_referencement_coverages)
        end
      end

      context 'remove institution_subject' do
        let(:institution_subject) { create :institution_subject, institution: institution }

        before { institution.institutions_subjects << institution_subject }

        it 'calls update_referencement_coverages' do
          allow(antenne).to receive(:update_referencement_coverages)
          institution.institutions_subjects.delete(institution_subject)
          expect(antenne).to have_received(:update_referencement_coverages)
        end
      end
    end
  end

  describe 'to_s' do
    it do
      institution = create :institution, name: 'Direccte'
      expect(institution.to_s).to eq 'Direccte'
    end
  end

  describe 'compute_slug' do
    let(:institution) { build :institution, name: "My Institution" }

    context 'manual call' do
      before { institution.compute_slug }

      it { expect(institution.slug).to eq 'my-institution' }
    end

    context 'before_validation hook' do
      before { institution.save }

      it do
        expect(institution.slug).to eq 'my-institution'
        expect(institution).to be_valid
      end
    end
  end
end

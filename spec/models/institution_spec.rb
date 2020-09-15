# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Institution, type: :model do
  it do
    is_expected.to have_many :experts
    is_expected.to validate_presence_of :name
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

      it { expect(institution.slug).to eq 'my_institution' }
    end

    context 'before_validation hook' do
      before { institution.save }

      it do
        expect(institution.slug).to eq 'my_institution'
        expect(institution).to be_valid
      end
    end
  end

  describe 'find_institution_subject' do
    subject { institution.find_institution_subject(label) }

    let(:institution) { create :institution, name: 'The Institution' }
    let(:theme) { create :theme, label: 'The Theme' }
    let(:the_subject) { create :subject, label: 'The Subject', theme: theme }
    let!(:is1) { create :institution_subject, institution: institution, subject: the_subject, description: 'First IS' }
    let!(:is2) { create :institution_subject, institution: institution, subject: the_subject, description: 'Second IS' }

    context 'label is not found' do
      let(:label) { 'other' }

      it{ is_expected.to be_nil }
    end

    context 'label is found and unique' do
      let(:label) { 'First IS' }

      it{ is_expected.to eq is1 }
    end

    context 'label is found but not unique' do
      let(:label) { 'The Subject' }

      it{ is_expected.to be_nil }
    end
  end
end

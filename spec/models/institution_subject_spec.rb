# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionSubject do
  describe 'validations' do
    it do
      is_expected.to belong_to :subject
      is_expected.to belong_to :institution
    end

    describe 'description uniqueness in an institution' do
      let(:institution) { create :institution }
      let(:the_subject) { create :subject }

      before do
        create :institution_subject, institution: institution, subject: the_subject, description: 'FOO'
      end

      context 'same institution and subject and description' do
        subject { build :institution_subject, institution: institution, subject: the_subject, description: 'FOO' }

        it { is_expected.not_to be_valid }
      end

      context 'same institution and subject, no description' do
        subject { build :institution_subject, institution: institution, subject: the_subject, description: '' }

        it { is_expected.not_to be_valid }
      end

      context 'same institution and subject, differetn description' do
        subject { build :institution_subject, institution: institution, subject: the_subject, description: 'BAR' }

        it { is_expected.to be_valid }
      end

      context 'same institution, other subject' do
        subject { build :institution_subject, institution: institution }

        it { is_expected.to be_valid }
      end

      context 'other institution, same subject' do
        subject { build :institution_subject, subject: the_subject }

        it { is_expected.to be_valid }
      end
    end
  end

  describe 'unique_name' do
    subject { institution_subject.unique_name }

    let(:institution_subject) { create :institution_subject, institution: institution, subject: the_subject, description: 'First IS' }
    let!(:other_institution_subject) { create :institution_subject, institution: institution, subject: other_subject, description: 'Second IS' }
    let(:the_subject) { create :subject, theme: theme, label: 'The Subject' }
    let(:institution) { create :institution }
    let(:theme) { create :theme, label: 'Label of the theme' }

    context 'with no other similar institution_subject' do
      let(:other_subject) { create :subject, theme: theme, label: 'Other subject' }

      it{ is_expected.to eq 'The Subject' }
    end

    context 'with a similar institution_subject' do
      let(:other_subject) { the_subject }

      it{ is_expected.to eq 'The Subject:First IS' }
    end
  end

  describe 'find_with_name' do
    subject { described_class.find_with_name(institution, label) }

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

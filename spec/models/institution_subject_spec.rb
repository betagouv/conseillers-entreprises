# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionSubject, type: :model do
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

  describe 'csv_identifier' do
    subject { institution_subject.csv_identifier }

    let(:institution_subject) { create :institution_subject, subject: the_subject, description: description }
    let(:the_subject) { create :subject, theme: theme, label: 'Label of the subject' }
    let(:theme) { create :theme, label: 'Label of the theme' }

    context 'with a description' do
      let(:description) { 'Description détaillée' }

      it{ is_expected.to eq 'Label of the theme:Label of the subject:Description détaillée' }
    end

    context 'with no description' do
      let(:description) { '' }

      it{ is_expected.to eq 'Label of the theme:Label of the subject' }
    end
  end
end

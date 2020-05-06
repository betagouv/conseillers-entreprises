# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solicitation, type: :model do
  describe 'associations' do
    it { is_expected.to have_many :diagnoses }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :landing_slug }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :full_name }
    it { is_expected.to validate_presence_of :phone_number }
    it { is_expected.to validate_presence_of :email }
  end

  describe '#landing_options' do
    let(:solicitation) { create :solicitation, landing_options_slugs: slugs }
    let!(:option1) { create :landing_option, slug: 'option1' }
    let!(:option2) { create :landing_option, slug: 'option2' }

    subject { solicitation.landing_options }

    context 'slugs are known' do
      let(:slugs) { %w[option1 option2] }

      it { is_expected.to match_array [option1, option2] }
    end

    context 'slugs are unknown' do
      let(:slugs) { %w[option3 option4] }

      it { is_expected.to be_empty }
    end
  end

  describe '#preselected_subjects' do
    let(:solicitation) { create :solicitation, landing_options: [option] }
    let(:option) { create :landing_option, preselected_subject_slug: preselected_subject_slug }
    let!(:subject1) { create :subject }

    subject { solicitation.preselected_subjects }

    context 'subject is known' do
      let(:preselected_subject_slug) { subject1.slug }

      it { is_expected.to eq [subject1] }
    end

    context 'subject is unknown' do
      let(:preselected_subject_slug) { 'some_slug' }

      it { is_expected.to be_empty }
    end
  end

  describe '#preselected_institutions' do
    let(:solicitation) { create :solicitation, landing_options: [option] }
    let(:option) { create :landing_option, preselected_institution_slug: preselected_institution_slug }
    let!(:institution1) { create :institution }

    subject { solicitation.preselected_institutions }

    context 'institution is known' do
      let(:preselected_institution_slug) { institution1.slug }

      it { is_expected.to eq [institution1] }
    end

    context 'institution is unknown' do
      let(:preselected_institution_slug) { 'some_institution' }

      it { is_expected.to be_empty }
    end
  end

  describe '#have_badge' do
    let(:badge) { create :badge, title: 'test' }
    let(:solicitation) { create :solicitation, badges: [badge] }
    let!(:solicitation_without_badge) { create :solicitation }

    subject { described_class.have_badge('test') }

    it { is_expected.to eq [solicitation] }
  end

  describe '#have_landing_option' do
    let(:solicitation) { create :solicitation, landing_options_slugs: ['landing_test_slug'] }
    let!(:solicitation_without_slug) { create :solicitation }

    subject { described_class.have_landing_option('landing_test_slug') }

    it { is_expected.to eq [solicitation] }
  end

  describe '#description_contains' do
    let(:solicitation) { create :solicitation, description: 'Description de test' }
    let!(:solicitation2) { create :solicitation, description: 'Une autre description' }

    subject { described_class.description_contains('test') }

    it { is_expected.to eq [solicitation] }
  end

  describe '#have_landing_slug' do
    let(:solicitation) { create :solicitation, landing_slug: 'landing_test' }
    let!(:solicitation_without_landing) { create :solicitation }

    subject { described_class.have_landing('test') }

    it { is_expected.to eq [solicitation] }
  end

  describe '#name_contains' do
    let(:solicitation) { create :solicitation, full_name: 'Pink Floyd' }
    let!(:solicitation2) { create :solicitation, full_name: 'Edith Piaf' }

    subject { described_class.name_contains('Pink') }

    it { is_expected.to eq [solicitation] }
  end

  describe '#email_contains' do
    let(:solicitation) { create :solicitation, email: 'kingju@wanadoo.fr' }
    let!(:solicitation2) { create :solicitation, email: 'edith@piaf.fr' }

    subject { described_class.email_contains('kingju') }

    it { is_expected.to eq [solicitation] }
  end
end

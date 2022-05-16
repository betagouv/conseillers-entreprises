# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonConcern do
  describe 'email_with_display_name' do
    subject { user.email_with_display_name }

    let(:user) { build :user, full_name: name, email: email }

    context 'Clean values' do
      let(:name) { 'Paul Mc Cartney' }
      let(:email) { 'paul@abbey.road' }

      it { is_expected.to eq '"Paul Mc Cartney" <paul@abbey.road>' }
    end

    context 'No name' do
      let(:name) { nil }
      let(:email) { 'paul@abbey.road' }

      it { is_expected.to eq 'paul@abbey.road' }
    end

    context 'No email' do
      let(:name) { 'Paul Mc Cartney' }
      let(:email) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe 'normalize_name' do
    subject { user.full_name }

    let(:user) { create :user, full_name: name }

    context 'Clean value' do
      let(:name) { 'Paul Mc Cartney' }

      it do
        user.normalize_name
        is_expected.to eq 'Paul Mc Cartney'
      end
    end

    context 'Dirty value' do
      let(:name) { ' paul 		 mcCartney  ' }

      it do
        user.normalize_name
        is_expected.to eq 'Paul McCartney'
      end
    end

    context 'With special caracters' do
      let(:name) { "hervé dupont-moriss d'alençon" }

      it do
        user.normalize_name
        is_expected.to eq "Hervé Dupont-Moriss D'Alençon"
      end
    end
  end

  describe 'normalize_phone_number' do
    subject { user.phone_number }

    let(:user) { create :user, phone_number: phone_number }

    context 'Clean value' do
      let(:phone_number) { '01 23 45 67 89' }

      it do
        user.normalize_phone_number
        is_expected.to eq '01 23 45 67 89'
      end
    end

    context 'Dirty value' do
      let(:phone_number) { '0123456789' }

      it do
        user.normalize_phone_number
        is_expected.to eq '01 23 45 67 89'
      end
    end

    context 'Other format' do
      let(:phone_number) { '01 23456789 abcd-12' }

      it do
        user.normalize_phone_number
        is_expected.to eq '01 23456789 abcd-12'
      end
    end
  end

  describe 'normalize_email' do
    subject { user.email }

    let(:user) { create :user, email: email }

    context 'Clean value' do
      let(:email) { 'user@host.com' }

      it do
        user.normalize_email
        is_expected.to eq 'user@host.com'
      end
    end

    context 'Dirty value' do
      let(:email) { ' USeR@HoST.cOm' }

      it do
        user.normalize_email
        is_expected.to eq 'user@host.com'
      end
    end
  end

  describe 'normalize_job' do
    subject { user.normalize_job }

    let(:user) { create :user, job: job }

    context 'Clean value' do
      let(:job) { 'Important Job Title' }

      it do
        user.normalize_job
        is_expected.to eq 'Important Job Title'
      end
    end

    context 'Dirty value' do
      let(:job) { ' IMPORTANT  job title		 ' }

      it do
        user.normalize_job
        is_expected.to eq 'Important Job Title'
      end
    end
  end
end

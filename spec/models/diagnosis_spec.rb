# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diagnosis, type: :model do
  it do
    is_expected.to have_many :needs
    is_expected.to belong_to :advisor
    # is_expected.to belong_to :visitee # TODO: We currently have bad data in DB, and cannot validate this
    is_expected.to belong_to :facility
    is_expected.to validate_presence_of :advisor
    is_expected.to validate_presence_of :facility
    is_expected.to validate_inclusion_of(:step).in_array(Diagnosis::AUTHORIZED_STEPS)
  end

  describe 'custom validations' do
    describe 'last_step_has_matches' do
      subject(:diagnosis) { build :diagnosis, step: Diagnosis::LAST_STEP }

      context 'no matches' do
        it { is_expected.not_to be_valid }
      end

      context 'with matches' do
        before do
          diagnosis.needs << build(:need, matches: [build(:match)])
        end

        it { is_expected.to be_valid }
      end
    end
  end

  describe 'callbacks' do
    describe 'last_step_notify' do
      let(:diagnosis) { create :diagnosis, step: old_step, needs: [build(:need, matches: [build(:match)])] }

      before do
        allow(diagnosis).to receive(:notify_experts!)
        diagnosis.step = new_step
        diagnosis.save!
      end

      context 'previous step' do
        let(:old_step) { Diagnosis::LAST_STEP - 2 }
        let(:new_step) { Diagnosis::LAST_STEP - 1 }

        it { expect(diagnosis).not_to have_received(:notify_experts!) }
      end

      context 'set last step' do
        let(:old_step) { Diagnosis::LAST_STEP - 1 }
        let(:new_step) { Diagnosis::LAST_STEP }

        it { expect(diagnosis).to have_received(:notify_experts!) }
      end

      context 'set last step again' do
        let(:old_step) { Diagnosis::LAST_STEP }
        let(:new_step) { Diagnosis::LAST_STEP }

        it { expect(diagnosis).not_to have_received(:notify_experts!) }
      end
    end
  end

  describe 'scopes' do
    describe 'in progress' do
      subject { Diagnosis.in_progress.count }

      it do
        create :diagnosis_completed
        create :diagnosis, step: 2
        create :diagnosis, step: 4

        is_expected.to eq 2
      end
    end

    describe 'completed' do
      subject { Diagnosis.completed.count }

      it do
        create :diagnosis_completed
        create :diagnosis_completed
        create :diagnosis, step: 4

        is_expected.to eq 2
      end
    end

    describe 'available_for_expert' do
      subject { Diagnosis.available_for_expert(expert) }

      let(:expert) { create :expert }

      context 'no diagnosis' do
        it { is_expected.to eq [] }
      end

      context 'one diagnosis' do
        let(:diagnosis) { create :diagnosis }
        let(:need) { create :need, diagnosis: diagnosis }
        let(:skill) { create :skill }

        before do
          create :match, need: need, expert: expert, skill: skill
        end

        it { is_expected.to eq [diagnosis] }
      end
    end
  end

  describe 'can_be_viewed_by?' do
    subject { diagnosis.can_be_viewed_by?(role) }

    let(:diagnosis) { create :diagnosis, advisor: advisor }
    let(:advisor) { create :user }

    context 'user is the diagnosis advisor' do
      let(:role) { advisor }

      it { is_expected.to eq true }
    end

    context 'user is unrelated' do
      let(:role) { create :user }

      it { is_expected.to eq false }
    end

    context 'expert is contacted for this diagnosis' do
      let(:role) { create :expert }

      before do
        need = create :need, diagnosis: diagnosis
        create :match, expert: role, need: need
      end

      it { is_expected.to eq true }
    end

    context 'expert has a relevant support skill' do
      let(:role) { create :expert, is_global_zone: true, skills: [skill] }
      let(:skill) { create :skill, subject: help_subject }
      let(:help_subject) { create :subject, is_support: true }

      it { is_expected.to eq true }
    end

    context 'expert is unrelated' do
      let(:role) { create :expert }

      it { is_expected.to eq false }
    end
  end

  describe 'match_and_notify!' do
    subject(:match_and_notify) { diagnosis.match_and_notify!(matches) }

    let(:diagnosis) { create :diagnosis, step: 4 }
    let(:need) { create :need, diagnosis: diagnosis }
    let(:expert_skill) { create(:expert_skill, skill: create(:skill), expert: create(:expert)) }
    let(:matches) { { need.id => [expert_skill.id] } }

    context 'selected skills for related needs' do
      it do
        expect{ match_and_notify }.to change(Match, :count).by(1)
        expect(Match.last.expert).to eq expert_skill.expert
        expect(Match.last.skill).to eq expert_skill.skill
        expect(diagnosis.step).to eq Diagnosis::LAST_STEP
      end
    end

    context 'no selected skills' do
      let(:matches) { { need.id => [] } }

      it { expect{ match_and_notify }.to raise_error ActiveRecord::RecordInvalid }
    end

    context 'unrelated need' do
      let(:need) { create :need }

      it { expect{ match_and_notify }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end

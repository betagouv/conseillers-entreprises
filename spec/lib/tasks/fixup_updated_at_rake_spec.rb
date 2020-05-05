require 'rails_helper'
require 'rake'

describe 'fixup_updated_at' do
  before do
    PlaceDesEntreprises::Application.load_tasks
    Rake::Task.define_task(:environment)
  end

  # In these specs, I’m creating empty models in lets,
  # then change the timestampos in a before statement.
  # This is because ActiveRecord:timestamp, rspec and factorybot prevent us
  # to set created_at and updated_at to arbitrary values.
  # I could use TimeCop, but it would require multiple travels; let’s just set the values manually.
  let(:day_0) { Time.new(2000,01,01,0,0,0,'+00:00') }
  let(:day_1) { day_0 + 1.day  }
  let(:day_2) { day_0 + 2.days }
  let(:day_3) { day_0 + 3.days }

  describe 'accidentally_touched_matches' do
    let(:right_match_1) { create :match }
    let(:right_match_2) { create :match }
    let(:wrong_match_1) { create :match }
    let(:wrong_match_2) { create :match }

    before do
      right_match_1.update_columns(created_at: day_0, taken_care_of_at: day_1, closed_at: day_2, updated_at: day_2)
      right_match_2.update_columns(created_at: day_0, taken_care_of_at: day_1, closed_at: nil, updated_at: day_1)
      wrong_match_1.update_columns(created_at: day_0, taken_care_of_at: day_1, closed_at: day_2, updated_at: day_3)
      wrong_match_2.update_columns(created_at: day_0, taken_care_of_at: day_1, closed_at: nil, updated_at: day_3)
    end

    it do
      Rake::Task['fixup_updated_at:accidentally_touched_matches'].invoke

      expect(right_match_1.reload.updated_at).to eq day_2
      expect(right_match_2.reload.updated_at).to eq day_1
      expect(wrong_match_1.reload.updated_at).to eq day_2
      expect(wrong_match_2.reload.updated_at).to eq day_1
    end
  end

  describe 'accidentally_touched_feedbacks' do
    let(:right_feedback) { create :feedback, :for_need }
    let(:wrong_feedback) { create :feedback, :for_need }

    before do
      right_feedback.update_columns(created_at: day_0, updated_at: day_0)
      wrong_feedback.update_columns(created_at: day_0, updated_at: day_1)
    end

    it do
      Rake::Task['fixup_updated_at:accidentally_touched_feedbacks'].invoke

      expect(right_feedback.reload.updated_at).to eq day_0
      expect(wrong_feedback.reload.updated_at).to eq day_0
    end
  end

  describe 'touch_needs' do
    let(:need_1) { create :need }
    let(:match_1) { create :match }
    let(:need_2) { create :need }
    let(:feedback_2) { create :feedback, :for_need }

    before do
      need_1.update_columns(created_at: day_0, updated_at: day_0)
      match_1.update_columns(need_id: need_1.id, created_at: day_0, updated_at: day_1)

      need_2.update_columns(created_at: day_0, updated_at: day_0)
      feedback_2.update_columns(feedbackable_id: need_2.id, created_at: day_0, updated_at: day_1)
    end

    it do
      Rake::Task['fixup_updated_at:touch_needs'].invoke

      expect(need_1.reload.updated_at).to eq day_1
      expect(need_2.reload.updated_at).to eq day_1
    end
  end

  describe 'touch_diagnoses' do
    let(:diagnosis_1) { create :diagnosis }
    let(:need_1) { create :need }

    before do
      diagnosis_1.update_columns(created_at: day_0, updated_at: day_0)
      need_1.update_columns(diagnosis_id: diagnosis_1.id, created_at: day_0, updated_at: day_1)
    end

    it do
      Rake::Task['fixup_updated_at:touch_diagnoses'].invoke

      expect(diagnosis_1.reload.updated_at).to eq day_1
    end
  end

  describe 'touch_solicitations' do
    let(:solicitation_1) { create :solicitation }
    let(:diagnosis_1) { create :diagnosis }
    let(:solicitation_2) { create :solicitation }
    let(:feedback_2) { create :feedback, :for_solicitation }

    before do
      solicitation_1.update_columns(created_at: day_0, updated_at: day_0)
      diagnosis_1.update_columns(solicitation_id: solicitation_1.id, created_at: day_0, updated_at: day_1)

      solicitation_2.update_columns(created_at: day_0, updated_at: day_0)
      feedback_2.update_columns(feedbackable_id: solicitation_2.id, created_at: day_0, updated_at: day_1)
    end

    it do
      Rake::Task['fixup_updated_at:touch_solicitations'].invoke

      expect(solicitation_1.reload.updated_at).to eq day_1
      expect(solicitation_2.reload.updated_at).to eq day_1
    end
  end
end

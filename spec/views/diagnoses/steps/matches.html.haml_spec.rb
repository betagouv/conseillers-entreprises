require "spec_helper"
require 'rails_helper'

describe "diagnoses/steps/matches", type: :view do
  let(:need) { create :need }
  let(:diagnosis) { create :diagnosis, needs: [need] }
  let(:institution_subject) { create :institution_subject, subject: need.subject }
  let(:support_subject) { create :subject, is_support: true }
  let(:institution_subject_support) { create :institution_subject, subject: support_subject }
  let(:expert_support) { create :expert, communes: [diagnosis.facility.commune] }
  let!(:expert_subject_support) { create :expert_subject, expert: expert_support, institution_subject: institution_subject_support }

  describe "diagnosis with experts" do
    let(:expert) { create :expert, communes: [diagnosis.facility.commune] }
    let!(:expert_subject) { create :expert_subject, expert: expert, institution_subject: institution_subject }

    it "displays experts" do
      assign(:diagnosis, diagnosis)

      render

      expect(response.body).to match expert.full_name
      expect(response.body).not_to match expert_support.full_name
    end
  end

  describe "diagnosis without experts" do
    it "display support expert" do
      assign(:diagnosis, diagnosis)

      render

      expect(response.body).to match expert_support.full_name
    end
  end
end

require "spec_helper"
require 'rails_helper'

describe "diagnoses/steps/matches.html.haml", type: :view do
  let(:need) { create :need }
  let(:diagnosis) { create :diagnosis, needs: [need] }
  let(:institution_subject) { create :institution_subject, subject: need.subject }
  let(:support_subject) { create :subject, is_support: true }
  let(:institution_subject_support) { create :institution_subject, subject: support_subject }
  let(:expert_support) { create :expert, communes: [diagnosis.facility.commune] }
  let!(:expert_subject_support) { create :expert_subject, expert: expert_support, institution_subject: institution_subject_support }

  describe "diagnosis with specialist" do
    let(:expert_specialist) { create :expert, communes: [diagnosis.facility.commune] }
    let!(:expert_subject_specialist) { create :expert_subject, expert: expert_specialist, institution_subject: institution_subject, role: 'specialist' }
    let(:expert_fallback) { create :expert, communes: [diagnosis.facility.commune] }
    let!(:expert_subject_fallback) { create :expert_subject, expert: expert_fallback, institution_subject: institution_subject, role: 'fallback' }

    it "display only specialists" do
      assign(:diagnosis, diagnosis)

      render

      expect(response.body).to match expert_specialist.full_name
      expect(response.body).not_to match expert_fallback.full_name
      expect(response.body).not_to match expert_support.full_name
    end
  end

  describe "diagnosis with fallback only" do
    let(:expert_fallback) { create :expert, communes: [diagnosis.facility.commune] }
    let!(:expert_subject_fallback) { create :expert_subject, expert: expert_fallback, institution_subject: institution_subject, role: 'fallback' }

    it "display fallback expert only" do
      assign(:diagnosis, diagnosis)

      render

      expect(response.body).to match expert_fallback.full_name
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

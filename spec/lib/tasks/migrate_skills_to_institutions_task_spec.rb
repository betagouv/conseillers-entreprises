# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "migrate_skills_to_institutions", type: :rake do
  describe 'move_skills' do
    let(:institution) { create :institution }
    let(:skill_un) { create :skill }
    let(:skill_deux) { create :skill }
    let!(:expert) { create :expert, antenne: create(:antenne, institution: institution), skills: [skill_un, skill_deux] }
    let(:rake_task) { Rake::Task["migrate_skills_to_institutions:move_skills"] }

    before {
      skill_un
      skill_deux
      expert
      institution
      rake_task.invoke
    }

    after { rake_task.reenable }

    it 'create 2 InstitutionSubject' do
      institution_subject_un = InstitutionSubject.find_by(institution: institution, subject: skill_un.subject, description: skill_un.title)
      institution_subject_deux = InstitutionSubject.find_by(institution: institution, subject: skill_deux.subject, description: skill_deux.title)

      expect(institution_subject_un).not_to be_nil
      expect(institution_subject_deux).not_to be_nil
    end

    it 'create 2 ExpertSubject' do
      insitution_subject_un = InstitutionSubject.first
      insitution_subject_deux = InstitutionSubject.last

      expert_subject_un = ExpertSubject.find_by(expert: expert, institution_subject: insitution_subject_un)
      expert_subject_deux = ExpertSubject.find_by(expert: expert, institution_subject: insitution_subject_deux)

      expect(expert_subject_un).not_to be_nil
      expect(expert_subject_deux).not_to be_nil
    end
  end

  describe 'add_subject_to_matches' do
    let(:institution) { create :institution }
    let(:subject_un) { create :subject }
    let(:default_subject) { create :subject, :default }
    let(:skill) { create :skill, subject: subject_un }
    let(:match_with_skill) { create :match, skill: skill }
    let(:match_without_skill) { create :match, skill: nil }
    let(:rake_task) { Rake::Task["migrate_skills_to_institutions:add_subject_to_matches"] }

    before {
      match_with_skill
      match_without_skill
      default_subject
      rake_task.invoke
    }

    after { rake_task.reenable }

    it 'add a subject to a match with skill' do
      expect(match_with_skill.reload.subject).to eq subject_un
    end

    it 'add a subject to a match without skill' do
      expect(match_without_skill.reload.subject).to eq default_subject
    end
  end
end

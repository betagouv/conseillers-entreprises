# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe Annuaire::UsersController do
  login_admin

  describe 'GET #index' do
    let(:institution_1) { create :institution }
    let(:subject_1) { create :subject }
    let!(:institution_subject) { create :institution_subject, institution: institution_1, subject: subject_1 }
    let!(:antenne_1) { create :antenne, communes: [commune_ouest], institution: institution_1 }
    let!(:user_1) { create :user, :invitation_accepted, antenne: antenne_1, experts: [expert_1] }
    let!(:expert_1) { create :expert, :with_expert_subjects, antenne: antenne_1 }
    let!(:expert_1_same_antenne) { create :expert, :with_expert_subjects, antenne: antenne_1 }
    let!(:antenne_2) { create :antenne, communes: [commune_est], institution: institution_1 }
    let!(:expert_2) { create :expert, :with_expert_subjects, antenne: antenne_2 }
    let!(:region_ouest) { create :territory, code_region: 1 }
    let!(:region_est) { create :territory, code_region: 2 }
    let!(:commune_ouest) { create :commune, regions: [region_ouest] }
    let!(:commune_est) { create :commune, regions: [region_est] }

    context 'with a user params' do
      subject(:request) { get :index, params: { institution_slug: institution_1.slug, advisor: user_1, antenne_id: antenne_1.id } }

      it 'return all users for the user antenne' do
        request
        expect(controller.send(:filtered_experts)).to contain_exactly(expert_1, expert_1_same_antenne)
        expect(assigns(:grouped_experts).keys).to contain_exactly(antenne_1)
        expect(assigns(:grouped_experts)[antenne_1].keys).to contain_exactly(expert_1, expert_1_same_antenne)
      end
    end

    context 'with an antenne params' do
      subject(:request) { get :index, params: { institution_slug: institution_1.slug, antenne_id: antenne_1.id } }

      it 'return all users for the antenne' do
        request
        expect(controller.send(:filtered_experts)).to contain_exactly(expert_1, expert_1_same_antenne)
        expect(assigns(:grouped_experts).keys).to contain_exactly(antenne_1)
        expect(assigns(:grouped_experts)[antenne_1].keys).to contain_exactly(expert_1, expert_1_same_antenne)
      end
    end

    context 'with an institution params' do
      subject(:request) { get :index, params: { institution_slug: institution_1.slug } }

      it 'return all users for the institution' do
        request
        expect(controller.send(:filtered_experts)).to contain_exactly(expert_1, expert_1_same_antenne, expert_2)
        expect(assigns(:grouped_experts).keys).to contain_exactly(antenne_1, antenne_2)
        expect(assigns(:grouped_experts)[antenne_1].keys).to contain_exactly(expert_1, expert_1_same_antenne)
        expect(assigns(:grouped_experts)[antenne_2].keys).to contain_exactly(expert_2)
      end
    end

    context 'with a manager without experts' do
      let!(:manager) { create :user, antenne: antenne_1 }

      before do
        manager.managed_antennes.push(antenne_1)
      end

      subject(:request) { get :index, params: { institution_slug: institution_1.slug } }

      it 'return all users for the institution' do
        request
        expect(controller.send(:filtered_experts)).to contain_exactly(expert_1, expert_1_same_antenne, expert_2)
        expect(assigns(:grouped_experts).keys).to contain_exactly(antenne_1, antenne_2)
        expect(assigns(:grouped_experts)[antenne_1].keys).to contain_exactly(
          expert_1,
                                                               expert_1_same_antenne,
                                                               an_instance_of(Expert).and(have_attributes(id: nil))
        )
      end
    end
  end

  describe '#POST send_invitations' do
    let(:institution) { create :institution }
    let!(:antenne) { create :antenne, institution: institution }
    let!(:user) { create :user, antenne: antenne, invitation_sent_at: nil }
    let(:one_day_ago) { 1.day.ago }
    let!(:old_user) { create :user, antenne: antenne, invitation_sent_at: one_day_ago }

    subject(:request) { post :send_invitations, params: { institution_slug: institution.slug, users_ids: "#{user.id} #{old_user.id}" } }

    before { request }

    it 'expect invitation sent to user' do
      expect(user.reload.invitation_sent_at).not_to be_nil
    end

    it 'don’t invite user which have already accept the invitation' do
      expect(old_user.reload.invitation_sent_at.beginning_of_hour).to eq one_day_ago.beginning_of_hour
    end
  end

  describe '#retrieve_users_without_experts' do
    let(:antenne) { create(:antenne) }
    let(:user_with_experts) { create(:user, antenne: antenne) }
    let!(:user_without_experts) { create(:user, antenne: antenne) }
    let!(:expert) { create(:expert, users: [user_with_experts]) }
    let(:grouped_experts) { { antenne => {} } }

    before do
      controller.instance_variable_set(:@grouped_experts, grouped_experts)
      controller.send(:retrieve_users_without_experts)
    end

    context 'normal user' do
      it 'adds users without experts' do
        expect(grouped_experts[antenne].keys).to include(an_instance_of(Expert))
        expect(grouped_experts[antenne].first.last).to include(user_without_experts)
      end

      it 'does not add users with experts' do
        expect(grouped_experts[antenne].keys).not_to include(expert)
      end
    end

    context 'manager' do
      before { user_without_experts.update(managed_antennes: [create(:antenne)]) }

      it 'does not add users who manage other antennes' do
        expect(grouped_experts[antenne].first.last).to include(user_without_experts)
      end
    end
  end

  describe '#retrieve_managers_without_experts' do
    let(:antenne) { create(:antenne) }
    let(:manager_with_experts) { create(:user, :manager, antenne: antenne) }
    let!(:manager_without_experts) { create(:user, :manager, antenne: antenne) }
    let!(:expert) { create(:expert, users: [manager_with_experts]) }
    let(:grouped_experts) { { antenne => {} } }

    before do
      controller.instance_variable_set(:@grouped_experts, grouped_experts)
      controller.send(:retrieve_managers_without_experts)
    end

    it 'adds managers without experts' do
      expect(grouped_experts[antenne].keys).to include(an_instance_of(Expert))
      expect(grouped_experts[antenne].first.last).to include(manager_without_experts)
    end

    it 'does not add managers with experts' do
      expect(grouped_experts[antenne].keys).not_to include(expert)
    end
  end
end

require 'rails_helper'

RSpec.describe DuplicateUser do
  describe '#duplicate_from' do
    let(:old_user) { create(:user, experts: [old_expert, old_team], user_rights: [build(:user_right, category: :manager, antenne: antenne)]) }
    let(:antenne) { build(:antenne) }
    let(:old_expert) do
      build(:expert,
             territorial_zones: [build(:territorial_zone, zone_type: "departement", code: "22")],
             match_filters: [build(:match_filter, min_years_of_existence: 2)])
    end
    let(:old_team) { build(:expert, users: build_list(:user, 2)) }
    let(:params) { { full_name: "My Name", email: "email@example.com", job: "My Job" } }

    it do
      new_user = User.duplicate_from(old_user, params)

      expect(new_user.full_name).to eq "My Name"
      expect(new_user.email).to eq "email@example.com"
      expect(new_user.job).to eq "My Job"

      expect(new_user.antenne).to eq old_user.antenne

      # single-user expert
      expect(new_user.experts).not_to include old_expert
      new_expert = new_user.single_user_experts.first
      expect(new_expert).not_to be_nil
      # territorial zones
      expect(new_expert.territorial_zones.first.zone_type).to eq "departement"
      expect(new_expert.territorial_zones.first.id).not_to eq old_expert.territorial_zones.first.id
      # match filters
      expect(new_expert.match_filters.first.min_years_of_existence).to eq 2
      expect(new_expert.match_filters.first.id).not_to eq old_expert.match_filters.first.id

      # teams
      expect(new_user.experts).to include old_team

      # user rights
      expect(new_user.user_rights.first.category).to eq "manager"
      expect(new_user.user_rights.first.id).not_to eq old_user.user_rights.first.id
    end
  end
end

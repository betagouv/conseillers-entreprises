require "rails_helper"

# Covers the app-owned :ajax_select input that replaced the activeadmin-ajax_filter
# gem, on the three resources it is most used with: expert, institution and subject.
RSpec.describe "Admin ajax_select inputs" do
  let(:admin) { create :user, :admin }

  before { login_as admin, scope: :user }

  describe "filters" do
    before { get "/admin/matches" }

    let(:expert_filter) { response.parsed_body.at_css("select[name='q[expert_id_eq]']") }

    it "renders the expert filter as an ajax select pointing at the experts endpoint" do
      expect(response).to have_http_status(:ok)
      expect(expert_filter).to be_present
      expect(expert_filter.attributes).to have_key("data-ajax-select")
      expect(expert_filter["data-url"]).to eq "/admin/experts"
      expect(expert_filter["data-search-param"]).to eq "full_name_cont"
      expect(expert_filter["data-label-field"]).to eq "full_name"
    end

    it "localises the widget wording" do
      expect(expert_filter["data-search-placeholder"]).to eq I18n.t("helpers.slim_select.search_placeholder")
    end
  end

  describe "form inputs" do
    let!(:match) { create :match }

    # The gem fetched the current value over ajax on page load; we render it
    # server side instead, so this guards against silently clearing the
    # association when an unrelated field is edited and the form is saved.
    it "renders the currently associated expert as a selected option" do
      get "/admin/matches/#{match.id}/edit"

      expect(response).to have_http_status(:ok)
      select = response.parsed_body.at_css("select[data-ajax-select][name='match[expert_id]']")
      expect(select).to be_present

      selected = select.css("option[selected]")
      expect(selected.pluck("value")).to eq [match.expert_id.to_s]
    end

    it "renders the currently associated institution on an antenne" do
      antenne = create :antenne

      get "/admin/antennes/#{antenne.id}/edit"

      expect(response).to have_http_status(:ok)
      select = response.parsed_body.at_css("select[data-ajax-select][name='antenne[institution_id]']")
      expect(select).to be_present
      expect(select.css("option[selected]").pluck("value")).to eq [antenne.institution_id.to_s]
    end
  end

  describe "the endpoint the widget queries" do
    it "answers json filtered by the ransack predicate the input advertises" do
      create :expert, full_name: "Jean Dupont"
      create :expert, full_name: "Marie Martin"

      get "/admin/experts", params: { q: { full_name_cont: "Dupont" } }, headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck("full_name")).to eq ["Jean Dupont"]
    end
  end
end

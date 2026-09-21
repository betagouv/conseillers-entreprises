require "rails_helper"

# The :datepicker input was renamed :date_picker and is now the native HTML date
# field, ahead of the ActiveAdmin 4 upgrade which drops the jQuery UI widget.
RSpec.describe "Admin date_picker inputs" do
  let(:admin) { create :user, :admin }
  let!(:user) { create :user }

  before { login_as admin, scope: :user }

  it "renders absence dates as native date fields keeping their lower bound" do
    get "/admin/users/#{user.id}/edit"

    expect(response).to have_http_status(:ok)

    field = response.parsed_body.at_css("input[name='user[absence_start_at]']")
    expect(field["type"]).to eq "date"
    expect(field["min"]).to eq Date.current.to_s
  end

  it "persists a date submitted by the native field" do
    patch "/admin/users/#{user.id}", params: { user: { absence_start_at: "2030-01-15" } }

    expect(user.reload.absence_start_at.to_date).to eq Date.new(2030, 1, 15)
  end
end

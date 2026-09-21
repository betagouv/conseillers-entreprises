require "rails_helper"

RSpec.describe "Admin::SolicitationMailTemplates" do
  let(:admin) { create :user, :admin }
  let!(:first_template) { create :solicitation_mail_template }
  let!(:second_template) { create :solicitation_mail_template }

  before { login_as admin, scope: :user }

  describe "GET /admin/solicitation_mail_templates" do
    it "renders a reorder handle pointing at the reorder action for each row" do
      get "/admin/solicitation_mail_templates"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include "reorder-handle"
      expect(response.body).to include reorder_admin_solicitation_mail_template_path(first_template)
      expect(response.body).to include reorder_admin_solicitation_mail_template_path(second_template)
    end
  end

  describe "POST /admin/solicitation_mail_templates/:id/reorder" do
    it "moves the template to the requested position" do
      target_position = second_template.reload.position

      post reorder_admin_solicitation_mail_template_path(first_template), params: { position: target_position }

      expect(response).to have_http_status(:ok)
      expect(first_template.reload.position).to eq target_position
      expect(second_template.reload.position).to be < target_position
    end
  end
end

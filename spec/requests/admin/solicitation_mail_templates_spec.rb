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

  describe "GET /admin/solicitation_mail_templates/:id/edit" do
    let(:editor) { response.parsed_body.at_css("[data-quill-editor]") }

    before { get edit_admin_solicitation_mail_template_path(first_template) }

    it "renders a Quill editor backed by a hidden field carrying the current html" do
      expect(response).to have_http_status(:ok)
      expect(editor).to be_present
      expect(editor.at_css("input[type=hidden]")["name"]).to eq "solicitation_mail_template[body_html]"
      expect(editor.at_css("[data-quill-content]").inner_html).to include first_template.body_html
    end

    it "does not emit duplicate ids for the editor and its hidden field" do
      ids = response.parsed_body.css("[id]").pluck("id")
      duplicates = ids.tally.select { |_id, count| count > 1 }.keys

      expect(duplicates).to be_empty
    end
  end

  describe "PATCH /admin/solicitation_mail_templates/:id" do
    it "persists the html submitted through the editor hidden field" do
      patch admin_solicitation_mail_template_path(first_template),
            params: { solicitation_mail_template: { body_html: "<p>Nouveau contenu</p>" } }

      expect(first_template.reload.body_html).to eq "<p>Nouveau contenu</p>"
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

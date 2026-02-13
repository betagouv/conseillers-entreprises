ActiveAdmin.register_page 'Reassign matches' do
  belongs_to :expert
  Formtastic::FormBuilder.perform_browser_validations = true

  page_action :reassign, method: :post do
    old_expert = Expert.find(params[:expert_id])
    selected_expert = Expert.find(params[:selected_expert_id])
    begin
      result = old_expert.reassign_matches(selected_expert)
      flash[:notice] = t('active_admin.expert.reassign_matches_done', count: result.count, expert: selected_expert)
      redirect_to admin_expert_path(old_expert)
    rescue StandardError => e
      flash[:alert] = I18n.t('activerecord.attributes.expert.errors.cant_transfer_match', error: e.message)
      redirect_to admin_expert_reassign_matches_path(old_expert)
    end
  end

  content title: I18n.t('active_admin.reassign_matches.title') do
    render partial: "reassign_matches", locals: { expert: Expert.find(params[:expert_id]) }
  end
end

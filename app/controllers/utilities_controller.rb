class UtilitiesController < SharedController
  def departments_to_regions
    code_region = I18n.t(params[:department], scope: 'departments_to_regions')
    respond_to do |format|
      format.json do
        render json: { code_region: code_region }
      end
    end
  end
end

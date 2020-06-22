class AdminController < ApplicationController
  def export_csv
    CsvJob.perform_later(params[:model], current_user)
    flash.notice = t('.job_launched')
    redirect_back fallback_location: admin_root_path
  end
end

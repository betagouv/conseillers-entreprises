class Conseiller::CsvExportsController < ApplicationController
  layout 'side_menu'

  def index
    authorize @user, policy_class: CsvExportPolicy
    @exports = current_user.csv_exports.includes(:blob).references(:blob).order('active_storage_blobs.created_at DESC')
  end

  def download
    @export = current_user.csv_exports.find(params[:id])
    authorize @export, policy_class: CsvExportPolicy

    respond_to do |format|
      format.html
      format.csv do
        send_data @export.download, type: "application/csv", filename: "#{@export.filename.to_s}.csv"
      end
    end
  end
end

class ReportsController < ApplicationController
  before_action :last_quarters

  def index
    authorize :report, :index?
  end

  def download_matches
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date
    xlsx_filename = t('.xslx_name', number: find_quarter(start_date.month), year: start_date.year)
    @matches = Match.joins(need: { experts: :antenne })
      .where(need: { experts: { antennes: [current_user.antenne] }, created_at: [start_date..end_date] })
      .where.not(need: { status: :diagnosis_not_complete })
      .distinct

    respond_to do |format|
      format.html
      format.xlsx do
        result = @matches.export_xlsx
        send_data result.xlsx, type: "application/xlsx", filename: xlsx_filename
      end
    end
  end

  private

  def last_quarters
    today = Date.today

    years = [today.year - 1, today.year]
    @quarters = []
    years.each do |year|
      @date ||= Date.parse("1.1.#{year}")
      4.times do
        next if @date.end_of_quarter > today
        @quarters << [@date.beginning_of_quarter, @date.end_of_quarter]
        @date = @date.end_of_quarter + 1.day
      end
    end
    @quarters = @quarters.last(4).reverse
  end

  def find_quarter(month)
    case month
    when 1,2,3
      t('reports.find_quarter.first')
    when 4,5,6
      t('reports.find_quarter.second')
    when 7,8,9
      t('reports.find_quarter.third')
    when 10,11,12
      t('reports.find_quarter.fourth')
    end
  end
end

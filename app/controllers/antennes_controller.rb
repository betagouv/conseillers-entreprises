class AntennesController < ApplicationController
  def index
    @antennes = institution.antennes.all
  end

  def new
    @antenne = institution.antennes.new
  end

  def create
    @antenne = institution.antennes.create!(params.permit(:name))

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("antennes",
          partial: "antennes/antenne",
          locals: { antenne: @antenne }
        )
      end

      format.html { redirect_to antennes_url }
    end
  end

  def institution
    @institution ||= Institution.find_by(slug: 'adie')
  end
end
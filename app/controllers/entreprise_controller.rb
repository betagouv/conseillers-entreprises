class EntrepriseController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'empty'

  def index
    slug = params[:slug]&.to_sym
    if !SLUGS.include?(slug)
      redirect_to root_path
    else
      @src = "http://reso-#{slug}.strikingly.com/"
    end
  end

  SLUGS = %i[
    cession
    reprise
    difficultes-financieres
    investissement
    strategie-numerique
    aide-publique
    joindre-l-administration
    a-qui-s-adresser
  ]
end

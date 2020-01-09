class PagesController < SharedController
  # Abstract Controller for the public pages
  # implicitly uses the 'pages' layout

  ## Configuration for honeypot-captcha
  #
  def honeypot_fields
    { :commentaire => 'Laissez ce champ vide !' }
  end
end

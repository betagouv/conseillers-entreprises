class String
  def sp_titleize_url
    self.titlecase.gsub(' ', '-').gsub('.Fr', '.fr')
  end
end
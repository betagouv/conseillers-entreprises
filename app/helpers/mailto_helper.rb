module MailtoHelper
  def mailto_contact_us(text = ENV['APPLICATION_EMAIL'])
    mail_to ENV['APPLICATION_EMAIL'], text, target: :_blank
  end
end

require 'rspec/expectations'

RSpec::Matchers.define :be_accessible do |expected|
  match do |actual|
    expect(actual).to be_axe_clean
    expect(actual).to have_skiplinks_ids

    @validator = W3CValidators::NuValidator.new
    WebMock.allow_net_connect!
    errors = @validator.validate_text(page.body).errors
    errors = filter_errors(errors)
    errors.each { |err| puts err }
    assert_equal 0, errors.length
  end

  def filter_errors(errors)
    errors.reject! do |e|
      # Erreur CSS dû au DSFR ou autre librairies
      e.message.include?('CSS') ||
        # DOCTYPE qui est apparemment mal interprété
        e.message.include?('<!DOCTYPE html>') ||
        # Erreur dû au DSFR qui cache une checkbox
        e.source.include?("<input name=\"user[remember_me]\"") ||
        # Erreur de la DIV Tarte au Citron pour les vidéos
        e.message.include?('Attribute “autoplay”') ||
        e.message.include?('Attribute “loop”') ||
        e.message.include?('Attribute “showinfo”') ||
        e.message.include?('Attribute “theme”') ||
        e.message.include?('Attribute “loading”') ||
        e.message.include?('Attribute “videoid”')
    end
  end
end

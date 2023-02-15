# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LandingSubject do
  describe 'autoclean_textareas' do
    let!(:landing_subject) do
      create :landing_subject,
             description: '<p>Description</p>',
             description_explanation: "<ul><li>votre activité </li><li>le statut de l'entreprise</li></ul><p><br></p>",
             description_prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de \r\n\r\nMerci d'avance pour votre appel",
             form_description: "<p><br></p><p>Quelque chose.</p><p><br></p>"
    end

    it do
      expect(landing_subject.description).to eq('<p>Description</p>')
      expect(landing_subject.description_explanation).to eq("<ul><li>votre activité </li><li>le statut de l'entreprise</li></ul>")
      expect(landing_subject.description_prefill).to eq("Bonjour,\r\n\r\nMon entreprise a une activité de \r\n\r\nMerci d'avance pour votre appel")
      expect(landing_subject.form_description).to eq('<p>Quelque chose.</p>')
    end
  end
end

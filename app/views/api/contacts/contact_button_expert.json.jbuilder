# frozen_string_literal: true

html = ERB::Util.html_escape render partial: 'contact_button_expert', formats: :html
json.html html

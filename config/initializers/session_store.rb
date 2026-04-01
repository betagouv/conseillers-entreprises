# Be sure to restart your server when you modify this file.

if Rails.env.test?
  # I can’t seem to make selenium trust the local certificate. refs #4374, #4364
  Rails.application.config.session_store :cookie_store, key: '_ConseillersEntreprises_session', same_site: :strict
else
  Rails.application.config.session_store :cookie_store, key: '_ConseillersEntreprises_session', same_site: :none, secure: true, partitioned: true
end

class UpdateCssForIframes < ActiveRecord::Migration[7.0]
  def change
    zetwal = Landing.find_by(slug: 'zetwal')
    zetwal.update(custom_css: '.section-grey, #section-thankyou { background-color: #ECF3FC !important; }.card, .landing-topic.block-link, .landing-subject { background-color: #ffffff !important; }.landing-topic.block-link { margin-right: 2rem !important; flex: 0 0 45% !important; padding: 20px !important}')
    fte = Landing.find_by(slug: 'france-transition-ecologique')
    fte.update(custom_css: '.section-grey { background-color: #ffffff !important; } .multistep-form input[type=text], .multistep-form textarea, .multistep-form input[type=tel], .multistep-form input[type=email] { background-color: #eee !important; }')
    brexit = Landing.find_by(slug: 'brexit')
    brexit.update(custom_css: '.fr-container-fluid, .section-grey, .fr-container .landing-subject-section, .landing-subject a, h2{ color: white !important; background-color: #223270 !important; } .landing-subject-section .discover_button { color: white !important; } input.button { color: white !important; background-color: #D32239 !important; } .multistep-form label { color: white !important; } a, p, span { color: #fff !important; } .landing-subject-section .fr-tile { background: none !important; box-shadow: none !important; } .thank_you_iframe .section__subtitle { color: #fff !important; }')
    relance = Landing.find_by(slug: 'relance-hautsdefrance')
    relance.update(custom_css: '.fr-container-fluid, .section-grey, .fr-container .landing-subject-section, .landing-subject a, h2{ color: white !important; background-color: #223270 !important; } .landing-subject-section .discover_button { color: white !important; } input.button { color: white !important; background-color: #D32239 !important; } .multistep-form label { color: white !important; } a, p, span { color: #fff !important; } .landing-subject-section .fr-tile { background: none !important; box-shadow: none !important; } .thank_you_iframe .section__subtitle { color: #fff !important; }')
  end
end

desc 'Create fake iframes for ux tests'
task fake_test_iframes: :environment do
  pde_institution = Institution.find_by(slug: 'equipe_place_des_entreprises')

  [
    { slug: 'iframe-test-1', title: 'Iframe test 1', custom_css: '.landing-theme-cards-container { grid-template-columns: repeat(1, 1fr); } .landing-subject-cards-container { grid-template-columns: repeat(1, 1fr) }', layout: "multiple_steps", iframe_category: "integral", display_pde_partnership_mention: true },
    { slug: 'iframe-test-2', title: 'Iframe test 2', custom_css: '.landing-theme-cards-container { grid-template-columns: repeat(2, 1fr); }', layout: "multiple_steps", iframe_category: "integral", display_pde_partnership_mention: true },
    { slug: 'iframe-test-3', title: 'Iframe test 3', layout: "multiple_steps", iframe_category: "integral", display_pde_partnership_mention: true },
  ].each do |params|
    landing = Landing.where(slug: params[:slug]).first_or_create!(
      iframe: true,
      institution_id: pde_institution.id,
      partner_url: 'https://reso-staging.osc-fr1.scalingo.io',
      title: params[:title],
      layout: params[:layout],
      iframe_category: params[:iframe_category],
      display_pde_partnership_mention: params[:display_pde_partnership_mention],
      custom_css: params[:custom_css]
    )
    landing.update_iframe_360
  end
end

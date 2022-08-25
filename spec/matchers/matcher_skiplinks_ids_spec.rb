require 'rspec/expectations'

RSpec::Matchers.define :have_skiplinks_ids do
  match do |page|
    expect(page).to have_css('#fr-skiplinks')
    expect(page).to have_css('#header-navigation')
    expect(page).to have_css('#content')
    expect(page).to have_css('#footer')
  end
end

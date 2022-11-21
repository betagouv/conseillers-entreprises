require 'rspec/expectations'

RSpec::Matchers.define :be_accessible do |expected|
  match do |actual|
    expect(actual).to be_axe_clean
    expect(actual).to have_skiplinks_ids
  end
end

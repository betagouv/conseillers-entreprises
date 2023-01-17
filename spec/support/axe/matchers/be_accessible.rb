require 'rspec/expectations'

RSpec::Matchers.define :be_accessible do |expected|
  match do |actual|
    expect(actual).to be_axe_clean
    expect(actual).to have_skiplinks_ids

    @validator = W3CValidators::NuValidator.new
    WebMock.allow_net_connect!
    errors = @validator.validate_text(page.body).errors
    errors.reject! { |e| e.message.include?('CSS')}
    errors.each { |err| puts err.to_s }
    assert_equal 0, errors.length
  end
end

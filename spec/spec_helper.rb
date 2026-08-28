# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require 'webmock/rspec'
require "pundit/rspec"
require 'axe-rspec'
require 'axe-capybara'
require 'active_support/testing/time_helpers'
require 'capybara/rspec'
require 'matchers/matcher_skiplinks_ids_spec'
# require 'rspec/retry'
require 'rails_helper'
include Pundit::Authorization

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  # `travel_to` without a block persists until reverted; reset it after every
  # example so a frozen time can never leak into later (order-random) examples.
  # Not redundant here: RSpec does not auto-revert travel_to like Minitest does.
  config.after { travel_back } # rubocop:disable Rails/RedundantTravelBack

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # ## Flacky tests
  # # show retry status in spec process
  # config.verbose_retry = true
  # # show exception that triggers a retry if verbose_retry is set to true
  # config.display_try_failure_messages = true

  # # run retry only on features
  # config.around :each, :flaky do |ex|
  #   ex.run_with_retry retry: 3
  # end

  config.order = :random
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailerHelper, type: :helper do
  describe 'text_key_for_step' do
    # enum status: { quo: 0, taking_care: 1, done: 2, not_for_me: 3 }, _prefix: true

    it 'returns waiting_for_answer when status is quo' do
      expect(helper.text_key_for_step('not_for_me', 'quo')).to eq('.waiting_for_answer')
      expect(helper.text_key_for_step('taking_care', 'quo')).to eq('.waiting_for_answer')
      expect(helper.text_key_for_step('done', 'quo')).to eq('.waiting_for_answer')
    end

    it 'returns taking_care when status is taking_care and old is quo' do
      expect(helper.text_key_for_step('quo', 'taking_care')).to eq('.taking_care')
    end

    it 'returns .not_finished when status is taking_care and old is done or not_for_me' do
      expect(helper.text_key_for_step('not_for_me', 'taking_care')).to eq('.not_finished')
      expect(helper.text_key_for_step('done', 'taking_care')).to eq('.not_finished')
    end

    it 'returns .done when status is done' do
      expect(helper.text_key_for_step('quo', 'done')).to eq('.done')
      expect(helper.text_key_for_step('taking_care', 'done')).to eq('.done')
      expect(helper.text_key_for_step('not_for_me', 'done')).to eq('.done')
    end

    it 'returns .not_for_me when status is not_for_me' do
      expect(helper.text_key_for_step('quo', 'not_for_me')).to eq('.not_for_me')
      expect(helper.text_key_for_step('taking_care', 'not_for_me')).to eq('.not_for_me')
      expect(helper.text_key_for_step('done', 'not_for_me')).to eq('.not_for_me')
    end
  end
end

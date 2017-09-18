# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'an email' do
  let(:mail) { subject }

  it 'has no empty fields' do
    expect(mail.to).not_to be_nil
    expect(mail.from).not_to be_nil
    expect(mail.body).not_to be_nil
    expect(mail.subject).not_to be_nil
  end

  it('has no HTML style tag') { expect(mail.body).not_to match('<style') }

  it 'has all translations' do
    expect(mail.body).not_to match('translation missing')
    expect(mail.subject).not_to match('translation missing')
  end

  it 'has all i18n variables injected' do
    expect(mail.body).not_to match(/%\{[a-z_]+\}/)
    expect(mail.subject).not_to match(/%\{[a-z_]+\}/)
  end
end

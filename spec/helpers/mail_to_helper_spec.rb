# frozen_string_literal: true

require 'rails_helper'

describe MailToHelper, type: :helper do
  before do
    user = create :user
    allow(helper).to receive(:current_user).and_return(user)
    ENV['APPLICATION_EMAIL'] = 'application@email'
  end

  describe 'expert_contact_button' do
    subject(:mail_to_button) do
      helper.expert_contact_button(visit: visit, question: question, assistance: assistance, expert: expert)
    end

    let(:visit) { create :visit, :with_visitee }
    let(:question) { create :question }
    let(:assistance) { create :assistance, :with_expert, question: question }
    let(:expert) { assistance.experts.first }

    it 'has the right href attribute' do
      expect(mail_to_button).to include "href=\"mailto:#{expert.email}"
      expect(mail_to_button).to include 'bcc=application%40email'
      expect(mail_to_button).to include 'subject=R%C3%A9so'
      expect(mail_to_button).to include 'body=Bonjour'
    end

    it 'has the right data attributes' do
      expect(mail_to_button).to include 'data-logged="false"'
      expect(mail_to_button).to include 'data-log-path="/mailto_logs'
      expect(mail_to_button).to include "mailto_log%5Bassistance_id%5D=#{assistance.id}"
      expect(mail_to_button).to include "mailto_log%5Bquestion_id%5D=#{question.id}"
      expect(mail_to_button).to include "mailto_log%5Bvisit_id%5D=#{visit.id}"
    end

    it 'has the right class and target attributes, and the right displayed text' do
      expect(mail_to_button).to include 'ui button green mailto-expert-button mini'
      expect(mail_to_button).to include 'target="_blank"'
      expect(mail_to_button).to include 'Contacter par e-mail</a>'
    end
  end

  describe 'institution_contact_button' do
    subject(:mail_to_button) do
      helper.institution_contact_button(visit: visit, question: question, assistance: assistance)
    end

    let(:visit) { create :visit, :with_visitee }
    let(:question) { create :question }
    let(:assistance) { create :assistance, question: question }

    it 'has the right href attribute' do
      expect(mail_to_button).to include "href=\"mailto:#{assistance.institution.email}"
      expect(mail_to_button).to include 'bcc=application%40email'
      expect(mail_to_button).to include 'subject=R%C3%A9so'
      expect(mail_to_button).to include 'body=Bonjour'
    end

    it 'has the right data attributes' do
      expect(mail_to_button).to include 'data-logged="false"'
      expect(mail_to_button).to include 'data-log-path="/mailto_logs'
      expect(mail_to_button).to include "mailto_log%5Bassistance_id%5D=#{assistance.id}"
      expect(mail_to_button).to include "mailto_log%5Bquestion_id%5D=#{question.id}"
      expect(mail_to_button).to include "mailto_log%5Bvisit_id%5D=#{visit.id}"
    end

    it 'has the right class and target attributes, and the right displayed text' do
      expect(mail_to_button).to include 'ui button green mailto-expert-button mini'
      expect(mail_to_button).to include 'target="_blank"'
      expect(mail_to_button).to include 'Contacter l&#39;institution par e-mail</a>'
    end
  end

  describe 'assistances_contact_all_button' do
    subject(:mail_to_button) do
      helper.assistances_contact_all_button(visit: visit, question: question, assistances: [assistance1, assistance2])
    end

    let(:visit) { create :visit, :with_visitee }
    let(:question) { create :question }

    let(:assistance1) { create :assistance, :with_expert, question: question }
    let!(:expert1) { assistance1.experts.first }
    let(:assistance2) { create :assistance, :with_expert, question: question }
    let!(:expert2) { assistance2.experts.first }

    it 'has the right href attribute' do
      expect(mail_to_button).to include "mailto:#{expert1.email}%2C#{expert2.email}"
      expect(mail_to_button).to include 'bcc=application%40email'
      expect(mail_to_button).to include 'subject=R%C3%A9so'
      expect(mail_to_button).to include 'body=Bonjour'
    end

    it 'has the right data attributes' do
      expect(mail_to_button).to include 'data-logged="false"'
      expect(mail_to_button).to include 'data-log-path="/mailto_logs'
      expect(mail_to_button).to include 'mailto_log%5Bassistance_id%5D=&amp;'
      expect(mail_to_button).to include "mailto_log%5Bquestion_id%5D=#{question.id}"
      expect(mail_to_button).to include "mailto_log%5Bvisit_id%5D=#{visit.id}"
    end

    it 'has the right class and target attributes, and the right displayed text' do
      expect(mail_to_button).to include 'ui button green mailto-expert-button'
      expect(mail_to_button).to include 'target="_blank"'
      expect(mail_to_button).to include 'Contacter tous en un e-mail</a>'
    end
  end
end

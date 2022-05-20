# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conseiller::SolicitationsController, type: :controller do
  login_admin

  describe 'index pages' do
    let!(:step_company) { create :solicitation, status: :step_company }
    let!(:step_description) { create :solicitation, status: :step_description, description: nil }
    let!(:in_progress) { create :solicitation, status: :in_progress }
    # solicitation in progress with feedback
    let!(:feedback) { create :feedback, :for_solicitation }
    let!(:processed) { create :solicitation, status: :processed }
    let!(:canceled) { create :solicitation, status: :canceled }

    describe 'GET #index' do
      subject(:request) { get :index }

      before { request }

      it { expect(assigns(:solicitations)).to contain_exactly(in_progress, feedback.solicitation) }
    end

    describe 'GET #processed' do
      subject(:request) { get :processed }

      before { request }

      it { expect(assigns(:solicitations)).to contain_exactly(processed) }
    end

    describe 'GET #canceled' do
      subject(:request) { get :canceled }

      before { request }

      it { expect(assigns(:solicitations)).to contain_exactly(canceled) }
    end
  end
end

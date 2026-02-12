require 'rails_helper'
require 'system_helper'

describe 'monitoring antennes' do
  login_admin
  let(:antenne) { create(:antenne) }

  before do
    # Mock the scope response as a proper ActiveRecord Relation, with all the attributes.
    antennes = Antenne.where(id: antenne.id)
      .select('*', Monitoring::MONITORING_ATTRIBUTES.map{ |name| "1 AS #{name}" }.join(','))
    allow(Antenne).to receive_messages(often_not_for_me: antennes,
                                       rarely_done: antennes,
                                       rarely_satisfying: antennes)
  end

  it 'displays antennes in collections' do
    visit monitoring_antennes_path

    expect(page).to have_current_path monitoring_antennes_path(collection: 'refus_frequents'), ignore_query: true
    expect(title).to eq "Suivi des antennes | Conseillers-Entreprises"

    expect(page).to have_text "1 Antenne"
    expect(page).to have_text antenne.name

    click_on "Peu d’aide proposée"
    expect(page).to have_current_path monitoring_antennes_path(collection: 'peu_d_aide_proposee'), ignore_query: true
    expect(page).to have_text "1 Antenne"
    expect(page).to have_text antenne.name

    click_on "Faible satisfaction"
    expect(page).to have_current_path monitoring_antennes_path(collection: 'faible_satisfaction'), ignore_query: true
    expect(page).to have_text "1 Antenne"
    expect(page).to have_text antenne.name
  end
end

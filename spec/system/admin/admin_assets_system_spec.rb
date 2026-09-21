require 'rails_helper'

# Guards the /admin asset bundle end to end.
#
# The rack_test specs only inspect server rendered HTML, so they stay green even
# when the compiled CSS or JS is broken. That is precisely the failure mode of the
# ActiveAdmin 4 upgrade, which swaps the whole stylesheet and drops jQuery, hence
# these assertions run in a real browser.
RSpec.describe 'Admin assets', :js do
  login_admin

  it 'applies the compiled stylesheet' do
    create :solicitation_mail_template

    visit '/admin/solicitation_mail_templates'

    expect(page).to have_css('.reorder-handle')
    cursor = page.evaluate_script("getComputedStyle(document.querySelector('.reorder-handle')).cursor")
    expect(cursor).to eq 'move'
  end

  it 'mounts the Quill editor on a rich text field' do
    template = create :solicitation_mail_template

    visit "/admin/solicitation_mail_templates/#{template.id}/edit"

    expect(page).to have_css('[data-quill-editor] .ql-editor')
    expect(page).to have_css('[data-quill-editor] .ql-toolbar')
  end

  it 'enhances ajax_select filters and fetches matching options from the server' do
    create :expert, full_name: 'Jean Dupont'

    visit '/admin/matches'

    # slim-select swaps the native select for its own markup once the JS has run
    expect(page).to have_css('.ss-main')

    find("select[name='q[expert_id_eq]']", visible: :all).sibling('.ss-main').click
    fill_in_search 'Dupont'

    expect(page).to have_css('.ss-option', text: 'Jean Dupont')
  end

  def fill_in_search(term)
    find('.ss-search input').set(term)
  end
end

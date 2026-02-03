def create_base_dummy_data
  create(:antenne)
  create(:badge)
  create(:company)
  create(:contact)
  create(:diagnosis)
  create(:expert_subject)
  create(:expert)
  create(:facility)
  create(:feedback, :for_need)
  create(:institution_subject)
  create(:institution, show_on_list: true)
  create(:landing)
  create(:landing_theme)
  create(:landing_subject)
  create(:match)
  create(:subject)
  create(:theme)
  create(:user)
  create(:solicitation)
  create(:solicitation_subject_answer)
  create(:need_subject_answer)
  create(:subject_answer_grouping)
end

def side_menu_link(path)
  within('#fr-sidemenu-wrapper') do
    find("a[href='#{path}']").sibling('span')
  end
end

def create_home_landing
  create(:landing, :with_subjects, slug: 'accueil', title: 'Accueil')
end

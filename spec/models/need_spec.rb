# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Need, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :diagnosis
      is_expected.to belong_to :subject
      is_expected.to have_many :matches
      is_expected.to belong_to :diagnosis
    end
  end

  describe 'subject uniqueness in the scope of a diagnosis' do
    subject { build :need, diagnosis: diagnosis, subject: subject1 }

    let(:diagnosis) { create :diagnosis }
    let(:subject1) { create :subject }

    context 'unique need for this subject' do
      it { is_expected.to be_valid }
    end

    context 'need for another subject' do
      before { create :need, diagnosis: diagnosis, subject: subject2 }

      let(:subject2) { create :subject }

      it { is_expected.to be_valid }
    end

    context 'need for the same subject' do
      before { create :need, diagnosis: diagnosis, subject: subject1 }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'update_status' do
    context 'after match changes' do
      let(:need) { create :need_with_matches }

      before { need.matches.first.update(status: :taking_care) }

      subject { need.reload.status }

      it { is_expected.to eq 'taking_care' }
    end

    context 'after diagnosis changes' do
      let(:need) { create :need }

      before do
        need.matches << create(:match)
      end

      it 'changes need status' do
        expect(need.status).to eq('diagnosis_not_complete')
        need.diagnosis.update(step: :completed)
        expect(need.reload.status).to eq('quo')
      end
    end
  end

  describe 'status' do
    subject { need.status }

    let(:need) { create :need, matches: matches, diagnosis: create(:diagnosis_completed) }

    context 'diagnosis not complete' do
      let(:need) { create :need, diagnosis: create(:diagnosis, step: :not_started) }

      it { is_expected.to eq 'diagnosis_not_complete' }
    end

    context 'with no match' do
      let(:matches) { [] }

      it{ is_expected.to eq 'diagnosis_not_complete' }
    end

    context 'diagnosis complete' do
      rules = {
        %i[quo quo] => 'quo',
        %i[quo not_for_me] => 'quo',
        %i[quo taking_care] => 'taking_care',
        %i[quo taking_care not_for_me] => 'taking_care',
        %i[quo done] => 'done',
        %i[quo taking_care not_for_me done] => 'done',
        %i[done done_no_help] => 'done',
        %i[done done_not_reachable done_no_help] => 'done',
        %i[quo done_no_help] => 'done_no_help',
        %i[taking_care done_no_help] => 'done_no_help',
        %i[done_not_reachable done_no_help] => 'done_no_help',
        %i[quo done_not_reachable not_for_me] => 'done_not_reachable',
        %i[not_for_me not_for_me] => 'not_for_me',
      }
      rules.each do |matches_statuses, need_status|
        # Building test dynamically for each rule
        context "#{matches_statuses.join(', ')} => #{need_status}" do
          let(:matches) { matches_statuses.map{ |status| build(:match, status: status) } }

          it{ is_expected.to eq need_status }
        end
      end
    end
  end

  describe 'scopes' do
    describe 'with_some_matches_in_status' do
      subject { described_class.with_some_matches_in_status(:done) }

      let(:need) { create :need }

      before { create :need }

      context 'with no match' do
        it { is_expected.to match_array [] }
      end

      context 'with matches, not done' do
        before do
          create :match, need: need, status: :quo
        end

        it { is_expected.to match_array [] }
      end

      context 'with matches, done' do
        before do
          create :match, need: need, status: :quo
          create :match, need: need, status: :done
        end

        it { is_expected.to match_array [need] }
      end
    end

    describe 'with_matches_only_in_status' do
      subject { described_class.with_matches_only_in_status(:quo) }

      let(:need1) { create :need }
      let(:need2) { create :need }
      let(:need3) { create :need }

      context 'with no match' do
        it { is_expected.to match_array [] }
      end

      context 'with various matches' do
        before do
          create_list :match, 2, status: :quo, need: need1
          create :match, status: :quo, need: need2
          create :match, status: :taking_care, need: need2
          create :match, status: :done, need: need3
          create :match, status: :not_for_me, need: need3
        end

        it { is_expected.to match_array [need1] }
      end
    end

    describe 'ordered_for_interview' do
      subject { described_class.ordered_for_interview }

      context 'with subjects and themes' do
        let(:t1)    { create :theme, interview_sort_order: 1 }
        let(:t2)    { create :theme, interview_sort_order: 2 }
        let(:s1)    { create :subject, interview_sort_order: 1, theme: t1 }
        let(:s2)    { create :subject, interview_sort_order: 2, theme: t1 }
        let(:s3)    { create :subject, interview_sort_order: 1, theme: t2 }
        let(:s4)    { create :subject, interview_sort_order: 2, theme: t2 }
        let(:need1) { create  :need, subject: s1 }
        let(:need2) { create  :need, subject: s2 }
        let(:need3) { create  :need, subject: s3 }
        let(:need4) { create  :need, subject: s4 }

        it { is_expected.to match_array [need1, need2, need3, need4] }
      end
    end

    describe 'active' do
      subject { described_class.active }

      let!(:need1) do
        create :need, matches: [
          create(:match, status: :quo),
          create(:match, status: :not_for_me),
        ]
      end
      let!(:need2) do
        create :need, matches: [
          create(:match, status: :taking_care),
          create(:match, status: :quo),
        ]
      end

      before do
        create :need, matches: [
          create(:match, status: :quo),
          create(:match, status: :done),
        ]
        create :need, matches: [
          create(:match, status: :not_for_me)
        ]
      end

      it { is_expected.to match_array [need1, need2] }
    end

    describe 'reminding_may_help' do
      # Base des scopes pour les relances il défini quand un besoin n'a pas reçu d'aide
      # 1 - besoin sans positionnement ok
      # 2 - besoin avec que des refus ko
      # 3 - besoin avec un positionnement et un refus ko
      # 4 - besoin avec un refus et un 'pas d'aide disponible' ko
      # 5 - besoin avec un refus et un 'pas joignable' ko
      # 6 - besoin sans positionnement et un 'pas d'aide disponible' ok
      # 7 - besoin sans positionnement et un 'pas joignable' ok
      # 8 - besoin avec le statut diagnosis_not_complete ko
      # 9 - besoin avec tous les positionnements en 'pas joignable' ko

      let!(:need1) { create :need_with_matches }
      let(:need2) { create :need }
      let!(:need2_match) { create :match, status: :not_for_me, need: need2 }
      let(:need3) { create :need }
      let!(:need3_match1) { create :match, status: :taking_care, need: need3 }
      let!(:need3_match2) { create :match, status: :not_for_me, need: need3 }
      let(:need4) { create :need }
      let!(:need4_match1) { create :match, status: :done_no_help, need: need4 }
      let!(:need4_match2) { create :match, status: :not_for_me, need: need4 }
      let(:need5) { create :need }
      let!(:need5_match1) { create :match, status: :done_not_reachable, need: need5 }
      let!(:need5_match2) { create :match, status: :not_for_me, need: need5 }
      let!(:need6) { create :need_with_matches }
      let!(:need6_match) { create :match, status: :done_no_help, need: need6 }
      let!(:need7) { create :need_with_matches }
      let!(:need7_match) { create :match, status: :done_not_reachable, need: need7 }
      let!(:need8) { create :need }
      let!(:need9) { create :need }
      let!(:need9_match1) { create :match, status: :done_not_reachable, need: need9 }
      let!(:need9_match2) { create :match, status: :done_not_reachable, need: need9 }

      it { expect(described_class.reminding_may_help).to match_array [need1, need6, need7] }
    end

    describe 'without_action' do
      # Exclue les besoins qui ont des reminders_action d'une catégorie en particulier
      # 1- besoin sans reminders_action
      # 2- besoin avec une action poke
      # 3- besoin avec une action recall
      # 4- besoin avec une action recall et une poke
      # 5- besoin avec une action warn
      # 6- besoin avec une action warn et une recall

      let!(:need1) { create :need }
      let(:need2) { create :need }
      let!(:reminders_action2) { create :reminders_action, category: :poke, need: need2 }
      let(:need3) { create :need }
      let!(:reminders_action3) { create :reminders_action, category: :recall, need: need3 }
      let(:need4) { create :need }
      let!(:reminders_action4) { create :reminders_action, category: :recall, need: need4 }
      let!(:reminders_action4_2) { create :reminders_action, category: :poke, need: need4 }
      let(:need5) { create :need }
      let!(:reminders_action5) { create :reminders_action, category: :warn, need: need5 }
      let(:need6) { create :need }
      let!(:reminders_action6) { create :reminders_action, category: :warn, need: need6 }
      let!(:reminders_action6_2) { create :reminders_action, category: :recall, need: need6 }

      it 'expect to have needs without poke action' do
        expect(described_class.without_action(:poke))
          .to match_array [need1, need3, need5, need6]
      end

      it 'expect to have needs without recall action' do
        expect(described_class.without_action(:recall))
          .to match_array [need1, need2, need5]
      end

      it 'expect to have needs without warn action' do
        expect(described_class.without_action(:warn))
          .to match_array [need1, need2, need3, need4]
      end
    end

    describe 'feedbacks' do
      let(:need) { create :need }
      let!(:feedback1) { create :feedback, :for_reminder, feedbackable: need }
      let!(:feedback2) { create :feedback, :for_need, feedbackable: need }

      it 'return only feedbacks for reminders' do
        expect(need.reminder_feedbacks).to match_array [feedback1]
      end

      it 'return only feedbacks for diagnosis page' do
        expect(need.feedbacks).to match_array [feedback2]
      end
    end

    describe 'user_antenne_territory_needs' do
      let(:commune_inside) { create :commune }
      let(:commune_outside) { create :commune }
      let(:facility_inside) { create :facility, commune: commune_inside }
      let(:facility_outside) { create :facility, commune: commune_outside }
      let(:institution) { create :institution }
      let(:antenne) { create :antenne, communes: [commune_inside], institution: institution }
      let(:another_antenne) { create :antenne, communes: [commune_inside], institution: institution }
      let(:expert) { create :expert_with_users, antenne: antenne }
      let(:expert_another_antenne) { create :expert_with_users, antenne: another_antenne }
      let(:a_subject) { create :subject }

      let(:a_month_ago) { Time.now - 1.month }
      let(:a_week_ago) { Time.now - 1.week }
      let(:now) { Time.now }

      # Dans les dates
      # Besoin dans la même antenne que l'utilisateur OK
      let!(:diagnosis_1) { create :diagnosis, facility: facility_inside, needs: [need_1] }
      let(:need_1) { create :need_with_matches }
      let!(:match_1) { create :match, need: need_1, expert: expert, subject: a_subject }
      # Besoin dans le périmètre de l'antenne avec l'institution dans les MER OK
      let!(:diagnosis_9) { create :diagnosis, facility: facility_inside, needs: [need_9] }
      let(:need_9) { create :need_with_matches }
      let!(:match_9) { create :match, need: need_9, expert: expert_another_antenne, subject: a_subject }
      # Besoin dans le perimeter de l'antenne sans l'institution dans les MER KO
      let!(:diagnosis_2) { create :diagnosis, facility: facility_inside, needs: [need_2] }
      let(:need_2) { create :need_with_matches }
      # Besoin en dehors du périmètre de l'antenne avec l'institution dans les MER KO / OK
      let!(:diagnosis_3) { create :diagnosis, facility: facility_outside, needs: [need_3] }
      let(:need_3) { create :need_with_matches }
      let!(:match_3) { create :match, need: need_3, expert: expert, subject: a_subject }
      # Besoin en dehors du périmètre de l'antenne sans l'institution dans les MER KO
      let!(:diagnosis_4) { create :diagnosis, facility: facility_outside, needs: [need_4] }
      let(:need_4) { create :need_with_matches }

      # En dehors des dates
      # Besoin dans le périmètre de l'antenne avec l'institution dans les MER KO
      let!(:diagnosis_5) { create :diagnosis, facility: facility_inside, needs: [need_5] }
      let(:need_5) { create :need_with_matches, created_at: a_month_ago }
      let!(:match_5) { create :match, need: need_5, expert: expert, subject: a_subject }
      # Besoin dans le périmètre de l'antenne sans l'institution dans les MER KO
      let!(:diagnosis_6) { create :diagnosis, facility: facility_inside, needs: [need_6] }
      let(:need_6) { create :need_with_matches, created_at: a_month_ago }
      # Besoin en dehors du périmètre de l'antenne avec l'institution dans les MER KO
      let!(:diagnosis_7) { create :diagnosis, facility: facility_outside, needs: [need_7] }
      let(:need_7) { create :need_with_matches, created_at: a_month_ago }
      let!(:match_7) { create :match, need: need_7, expert: expert, subject: a_subject }
      # Besoin en dehors du périmètre de l'antenne sans l'institution dans les MER KO
      let!(:diagnosis_8) { create :diagnosis, facility: facility_outside, needs: [need_8] }
      let(:need_8) { create :need_with_matches, created_at: a_month_ago }

      subject { described_class.user_antenne_territory_needs(user, a_week_ago, now) }

      context 'expert with antenne territory' do
        let(:user) { create :user, :invitation_accepted, antenne: antenne }

        it { is_expected.to match_array [need_1, need_9] }
      end

      context 'expert with national territory' do

      end
    end
  end

  describe 'abandoned' do
    let(:need) { create :need_with_matches }
    let(:date1) { 2.months.ago }
    let(:old_need) { travel_to(date1) { create :need_with_matches } }

    it do
      expect(need).not_to be_abandoned
      expect(old_need).to be_abandoned
      expect(described_class.abandoned).to match_array([old_need])

      travel_to(2.months.from_now) do
        expect(need).to be_abandoned
        expect(old_need).to be_abandoned
        expect(described_class.abandoned).to match_array([need, old_need])
      end
    end
  end

  describe 'touch diagnosis' do
    let(:date1) { Time.zone.now.beginning_of_day }
    let(:date2) { date1 + 1.minute }
    let(:date3) { date1 + 2.minutes }

    let(:diagnosis) { travel_to(date1) { create :diagnosis } }

    before { diagnosis }

    subject { diagnosis.reload.updated_at }

    context 'when a need is added to a diagnosis' do
      let(:need) { travel_to(date3) { create :need, diagnosis: diagnosis } }

      before do
        need
        travel_to(date3) { diagnosis.needs = [need] }
      end

      it { is_expected.to eq date3 }
    end

    context 'when a need is removed from a diagnosis' do
      let(:need) { travel_to(date1) { create :need, diagnosis: diagnosis } }

      before do
        need
        travel_to(date3) { need.destroy }
      end

      it { is_expected.to eq date3 }
    end

    context 'when a need is updated' do
      let(:need) { travel_to(date1) { create :need, diagnosis: diagnosis } }

      before do
        need
        travel_to(date3) { need.update(content: 'New content') }
      end

      it { is_expected.to match_array date3 }
    end
  end

  describe 'paniers relance' do
    describe 'besoins à relancer (J+7)' do
      # - besoins restés sans réponse (=sans positionnement, personne a cliqué sur les boutons "je prends en charge" ou "je refuse") à plus 7 jours après les mises en relation ;
      # - besoins avec une mise en relation clôturée par « pas d’aide disponible » et « non joignable » ou refusés ET pour lesquels des experts n’ont toujours pas répondu à plus de 7 jours.

      describe 'contraintes de délais' do
        # DELAIS
        # - besoin créé il y a 06 jours, sans positionnement     ko
        # - besoin créé il y a 07 jours, sans positionnement     ok
        # - besoin créé il y a 13 jours, sans positionnement     ok
        # - besoin créé il y a 14 jours, sans positionnement     ko

        let(:reference_date) { Time.zone.now.beginning_of_day }

        let(:need1) { travel_to(reference_date - 6.days)  { create :need_with_matches } }
        let(:need2) { travel_to(reference_date - 7.days)  { create :need_with_matches } }
        let(:need3) { travel_to(reference_date - 13.days) { create :need_with_matches } }
        let(:need4) { travel_to(reference_date - 14.days) { create :need_with_matches } }

        before do
          need1
          need2
          need3
          need4
        end

        it 'retourne les besoins dans la bonne période' do
          expect(described_class.reminders_to(:poke)).to match_array [need2, need3]
        end
      end

      describe 'contraintes de Reminder Action' do
        # - besoin créé il y a 07 jours, sans positionnement, pas marqué "traité", avec commentaire  ok
        # - besoin créé il y a 07 jours, sans positionnement, marqué "traité"                        ko
        # - besoin créé il y a 07 jours, avec positionnement, pas marqué "traité"                    ko
        # - besoin créé il y a 07 jours, avec positionnement, marqué "traité"                        ko

        let(:seven_days_ago) { Time.zone.now.beginning_of_day - 7.days }

        let!(:need1) { travel_to(seven_days_ago) { create :need_with_matches } }
        let!(:feedback1) { create :feedback, :for_need, feedbackable: need1 }
        let!(:need2) { travel_to(seven_days_ago) { create :need_with_matches } }
        let!(:reminders_action2) { create :reminders_action, category: :poke, need: need2 }
        let!(:need3) { travel_to(seven_days_ago) { create :need_with_matches } }
        let!(:need3_match) { travel_to(seven_days_ago) { create :match, need: need3, status: :taking_care } }
        let!(:need4) { travel_to(seven_days_ago) { create :need_with_matches } }
        let!(:need4_match) { travel_to(seven_days_ago) { create :match, need: need4, status: :taking_care } }
        let!(:reminders_action4) { create :reminders_action, category: :poke, need: need4 }

        before do
          need1.reload
          need2.reload
          need3.reload
          need4.reload
        end

        it 'retourne les besoins sans Reminder Action' do
          expect(described_class.reminders_to(:poke)).to match_array [need1]
        end
      end

      describe 'contraintes de relations' do
        # - besoin créé il y a 07 jours, avec 1 positionnement « refusé », et autres MER sans réponse           ok
        # - besoin créé il y a 07 jours, avec 1 cloture « pas d’aide disponible », et autres MER sans réponse   ok
        # - besoin créé il y a 07 jours, avec 1 cloture « injoignable », et autres MER sans réponse             ok
        # - besoin créé il y a 07 jours, avec 1 commentaire                                                     ok

        let(:seven_days_ago) { Time.zone.now.beginning_of_day - 7.days }

        let!(:need1) { travel_to(seven_days_ago) { create :need_with_matches } }
        let!(:need1_match) { travel_to(seven_days_ago) { create :match, need: need1, status: :not_for_me } }
        let!(:need2) { travel_to(seven_days_ago) { create :need_with_matches } }
        let!(:need2_match) { travel_to(seven_days_ago) { create :match, need: need2, status: :done_no_help } }
        let!(:need3) { travel_to(seven_days_ago) { create :need_with_matches } }
        let!(:need3_match) { travel_to(seven_days_ago) { create :match, need: need3, status: :done_not_reachable } }
        let!(:need4) { travel_to(seven_days_ago) { create :need_with_matches } }
        let!(:feedback4) { create :feedback, :for_need, feedbackable: need4 }

        before do
          need1.reload
          need2.reload
          need3.reload
          need4.reload
        end

        it 'retourne les besoins avec certaines relations' do
          expect(described_class.reminders_to(:poke)).to match_array [need1, need2, need3, need4]
        end
      end
    end

    describe 'besoins à rappeler (J+14)' do
      # - besoins restés sans réponse à plus 14 jours après les mises en relation ;
      # - besoins avec une mise en relation clôturée par « pas d’aide disponible » et « non joignable » ou refusés ET pour lesquels des experts n’ont toujours pas répondu à plus de 14 jours.

      describe 'contraintes de délais' do
        # - besoin créé il y a 13 jours, sans positionnement     ko
        # - besoin créé il y a 14 jours, sans positionnement     ok
        # - besoin créé il y a 20 jours, sans positionnement     ok
        # - besoin créé il y a 21 jours, sans positionnement     ko

        let(:reference_date) { Time.zone.now.beginning_of_day }

        let(:need1) { travel_to(reference_date - 13.days) { create :need_with_matches } }
        let(:need2) { travel_to(reference_date - 14.days) { create :need_with_matches } }
        let(:need3) { travel_to(reference_date - 20.days) { create :need_with_matches } }
        let(:need4) { travel_to(reference_date - 21.days) { create :need_with_matches } }

        before do
          need1
          need2
          need3
          need4
        end

        it 'retourne les besoins dans la bonne période' do
          expect(described_class.reminders_to(:recall)).to match_array [need2, need3]
        end
      end

      describe 'contraintes de Reminder Action' do
        # REMINDER ACTIONS
        # - besoin créé il y a 14 jours, sans positionnement, pas marqué "traité J+14"             ok
        # - besoin créé il y a 14 jours, sans positionnement, que marqué "traité J+7"              ok
        # - besoin créé il y a 14 jours, sans positionnement, marqué "traité J+14"                 ko
        # - besoin créé il y a 14 jours, avec positionnement, pas marqué "traité J+14"             ko
        # - besoin créé il y a 14 jours, avec positionnement, marqué "traité J+14"                 ko
        # - besoin créé il y a 14 jours, sans positionnement, marqué "traité J+7" et "traité J+14" ko

        let(:fourteen_days_ago) { Time.zone.now.beginning_of_day - 14.days }
        let!(:need1) { travel_to(fourteen_days_ago) { create :need_with_matches } }
        let(:need2) { travel_to(fourteen_days_ago) { create :need_with_matches } }
        let!(:reminders_action2) { create :reminders_action, category: :poke, need: need2 }
        let(:need3) { travel_to(fourteen_days_ago) { create :need_with_matches } }
        let!(:reminders_action3) { create :reminders_action, category: :recall, need: need3 }
        let!(:need4) { travel_to(fourteen_days_ago) { create :need, matches: [create(:match, status: :taking_care)] } }
        let(:need5) { travel_to(fourteen_days_ago) { create :need, matches: [create(:match, status: :taking_care)] } }
        let!(:reminders_action5) { create :reminders_action, category: :recall, need: need5 }
        let(:need6) { travel_to(fourteen_days_ago) { create :need_with_matches } }
        let!(:reminders_action6) { create :reminders_action, category: :poke, need: need6 }
        let!(:reminders_action7) { create :reminders_action, category: :recall, need: need6 }

        it 'retourne les besoins sans Reminder Action' do
          expect(described_class.reminders_to(:recall)).to match_array [need1, need2]
        end
      end

      describe 'contraintes de status' do
        # - besoin créé il y a 14 jours, avec 1 positionnement « refusé », et autres MER sans réponse           ok
        # - besoin créé il y a 14 jours, avec 1 cloture « pas d’aide disponible », et autres MER sans réponse   ok
        # - besoin créé il y a 14 jours, avec 1 cloture « injoignable », et autres MER sans réponse             ok

        let(:fourteen_days_ago) { Time.zone.now.beginning_of_day - 14.days }

        let!(:need1) { travel_to(fourteen_days_ago) { create :need_with_matches } }
        let!(:need1_match) { travel_to(fourteen_days_ago) { create :match, need: need1, status: :not_for_me } }
        let!(:need2) { travel_to(fourteen_days_ago) { create :need_with_matches } }
        let!(:need2_match) { travel_to(fourteen_days_ago) { create :match, need: need2, status: :done_no_help } }
        let!(:need3) { travel_to(fourteen_days_ago) { create :need_with_matches } }
        let!(:need3_match) { travel_to(fourteen_days_ago) { create :match, need: need3, status: :done_not_reachable } }

        before do
          need1.reload
          need2.reload
          need3.reload
        end

        it 'retourne les besoins avec certains status' do
          expect(described_class.reminders_to(:recall)).to match_array [need1, need2, need3]
        end
      end
    end

    describe 'besoins prévenir l’institution (J+21)' do
      # - besoins restés sans réponse à plus 21 jours après les mises en relation ;
      # - besoins avec une mise en relation clôturée par « pas d’aide disponible » et « non joignable » ou refusés ET pour lesquels des experts n’ont toujours pas répondu à plus de 21 jours.

      describe 'contraintes de délais' do
        let(:reference_date) { Time.zone.now.beginning_of_day }

        let(:need1) { travel_to(reference_date - 20.days) { create :need_with_matches } }
        let(:need2) { travel_to(reference_date - 21.days) { create :need_with_matches } }
        let(:need3) { travel_to(reference_date - 29.days) { create :need_with_matches } }
        let(:need4) { travel_to(reference_date - 30.days) { create :need_with_matches } }

        before do
          need1
          need2
          need3
          need4
        end

        it 'retourne les besoins dans la bonne période' do
          expect(described_class.reminders_to(:warn)).to match_array [need2, need3]
        end
      end

      describe 'contraintes de Reminder Action' do
        # REMINDER ACTIONS
        # - besoin créé il y a 21 jours, sans positionnement, pas marqué "traité J+21"              ok
        # - besoin créé il y a 21 jours, sans positionnement, que marqué "traité J+7"               ok
        # - besoin créé il y a 21 jours, sans positionnement, marqué "traité J+21"                  ko
        # - besoin créé il y a 21 jours, avec positionnement, pas marqué "traité J+21"              ko
        # - besoin créé il y a 21 jours, avec positionnement, marqué "traité J+21"                  ko
        # - besoin créé il y a 21 jours, sans positionnement, marqué "traité J+7", "J+14" et "J+21" ko

        let(:twenty_one_days_ago) { Time.zone.now.beginning_of_day - 21.days }
        let!(:need1) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let(:need2) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let!(:reminders_action2) { create :reminders_action, category: :poke, need: need2 }
        let(:need3) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let!(:reminders_action3) { create :reminders_action, category: :warn, need: need3 }
        let!(:need4) { travel_to(twenty_one_days_ago) { create :need, matches: [create(:match, status: :taking_care)] } }
        let(:need5) { travel_to(twenty_one_days_ago) { create :need, matches: [create(:match, status: :taking_care)] } }
        let!(:reminders_action5) { create :reminders_action, category: :warn, need: need5 }
        let(:need6) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let!(:reminders_action6) { create :reminders_action, category: :poke, need: need6 }
        let!(:reminders_action7) { create :reminders_action, category: :recall, need: need6 }
        let!(:reminders_action8) { create :reminders_action, category: :warn, need: need6 }

        it 'retourne les besoins sans Reminder Action' do
          expect(described_class.reminders_to(:warn)).to match_array [need1, need2]
        end
      end
    end

    describe 'Besoins abandonnés (J+30 ou refusés)' do
      # - besoins restés sans réponse de tous les experts à plus 30 jours après les mises en relation
      # - besoins avec une mise en relation refusée ET pour lesquels des experts n’ont toujours pas répondu à plus de 30 jours.
      # - besoins refusés de tous les experts

      describe 'contraintes de délais' do
        # - besoin créé il y a 29 jours, sans prise en charge     ko
        # - besoin créé il y a 30 jours, sans prise en charge     ok
        # - besoin créé il y a 100 jours, sans prise en charge    ok

        let(:reference_date) { Time.zone.now.beginning_of_day }

        let!(:need1) { travel_to(reference_date - 29.days) { create :need_with_matches } }
        let!(:need2) { travel_to(reference_date - 30.days) { create :need_with_matches } }
        let!(:need3) { travel_to(reference_date - 100.days) { create :need_with_matches } }

        it 'retourne les besoins dans la bonne période' do
          expect(described_class.reminders_to(:archive)).to match_array [need2, need3]
        end
      end

      describe 'contraintes d’archivage' do
        # - besoin créé il y a 30 jours, sans prise en charge, pas marqué "traité J+30"   ok
        # - besoin créé il y a 30 jours, sans prise en charge, marqué "traité J+30"       ko
        # - besoin créé il y a 30 jours, avec prise en charge, pas marqué "traité J+30"   ko
        # - besoin créé il y a 30 jours, avec prise en charge, marqué "traité J+30"       ko

        let!(:current_date) { Time.zone.now.beginning_of_day }
        let(:thirty_days_ago) { current_date - 30.days }

        let!(:need1) { travel_to(thirty_days_ago) { create :need_with_matches } }
        let!(:need2) { travel_to(thirty_days_ago) { create :need_with_matches, archived_at: current_date } }
        let!(:need3) { travel_to(thirty_days_ago) { create :need_with_matches } }
        let!(:need3_match) { travel_to(thirty_days_ago) { create :match, need: need3, status: :taking_care } }
        let!(:need4) { travel_to(thirty_days_ago) { create :need_with_matches, archived_at: current_date } }
        let!(:need4_match) { travel_to(thirty_days_ago) { create :match, need: need4, status: :taking_care } }

        it 'retourne les besoins non archivés' do
          expect(described_class.reminders_to(:archive)).to match_array [need1]
        end
      end

      describe 'contraintes de status' do
        # - besoin créé il y a 30 jours, avec 1 positionnement « refusé », et autres MER sans réponse           ok
        # - besoin créé il y a 30 jours, avec 1 cloture « pas d’aide disponible », et autres MER sans réponse   ko
        # - besoin créé il y a 30 jours, avec 1 cloture « injoignable », et autres MER sans réponse             ko
        # - besoin créé il y a moins de 30 jours, avec tous les positionnement « refusé »                       ok

        let(:thirty_days_ago) { Time.zone.now.beginning_of_day - 30.days }

        let!(:need1) { travel_to(thirty_days_ago) { create :need_with_matches } }
        let!(:need1_match) { travel_to(thirty_days_ago) { create :match, need: need1, status: :not_for_me } }
        let!(:need2) { travel_to(thirty_days_ago) { create :need_with_matches } }
        let!(:need2_match) { travel_to(thirty_days_ago) { create :match, need: need2, status: :done_no_help } }
        let!(:need3) { travel_to(thirty_days_ago) { create :need_with_matches } }
        let!(:need3_match) { travel_to(thirty_days_ago) { create :match, need: need3, status: :done_not_reachable } }
        let(:need4) { create :need }
        let!(:need4_match1) { create :match, need: need4, status: :not_for_me }
        let!(:need4_match2) { create :match, need: need4, status: :not_for_me }

        before do
          need1.reload
          need2.reload
          need3.reload
          need4.reload
        end

        it 'retourne les besoins avec certaines relations' do
          expect(described_class.reminders_to(:archive)).to match_array [need1, need4]
        end
      end
    end

    # describe 'Besoins pris en charge sans cloture' do
    #   # - besoins pris en charge mais n’ayant aucune mise en relation de clôturée depuis + 7 jours de la prise en charge.
    #   # DELAIS
    #   # - besoin avec un positionnement « prise en charge  » il y a 6 jours    ko
    #   # - besoin avec un positionnement « prise en charge  » il y a 7 jours    ok

    #   # STATUT
    #   # - besoin avec un positionnement « prise en charge  » il y a 7 jours et une cloture                ko
    #   # - besoin avec un positionnement « prise en charge  » il y a 7 jours et un autre il y a 2 jours    ok
    # end

    describe 'reminder' do
      let(:date1) { Time.zone.now.beginning_of_day }
      let(:date2) { date1 - 11.days }
      let(:date3) { date1 - 31.days }
      let(:new_need) { travel_to(date1) { create :need_with_matches } }
      let(:mid_need) { travel_to(date2) { create :need_with_matches } }
      let(:old_need) { travel_to(date3) { create :need_with_matches } }

      before do
        new_need
        mid_need
        old_need
      end

      subject { described_class.in_reminders_range(:poke) }

      it 'expect to have needs between 10 and 30 days' do
        is_expected.to match_array [mid_need]
      end
    end
  end

  describe 'search' do
    let(:subject1) { create :subject, label: "sujet un" }
    let(:subject2) { create :subject, label: "sujet deux" }
    let(:diagnosis1) { create :diagnosis, company: create(:company, name: "Entreprise deux") }
    let(:need1) { create :need, content: "la la" }
    let(:need2) { create :need, content: "la lo", subject: subject2 }
    let(:need3) { create :need, content: "lo deux", subject: subject1 }
    let(:need4) { create :need, content: "li li", diagnosis: diagnosis1 }

    it 'searches content' do
      expect(described_class.omnisearch("la")).to match_array [need1, need2]
    end

    it 'searches subject' do
      expect(described_class.omnisearch("sujet un")).to match_array [need3]
    end

    it 'searches multiple fields' do
      expect(described_class.omnisearch("deux")).to match_array [need2, need3, need4]
    end
  end
end

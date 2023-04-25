module  Annuaire
  class UsersController < BaseController
    before_action :retrieve_institution
    before_action :retrieve_antenne, only: [:index, :index_better]
    before_action :retrieve_users, only: [:index, :index_better]

    def index
      institutions_subjects_by_theme = @institution.institutions_subjects
        .preload(:subject, :theme, :experts_subjects, :not_deleted_experts)
        .group_by(&:theme)
      institutions_subjects_exportable = institutions_subjects_by_theme.values.flatten

      @grouped_subjects = institutions_subjects_by_theme.transform_values{ |is| is.group_by(&:subject) }

      @not_invited_users = not_invited_users

      respond_to do |format|
        format.html
        format.csv do
          result = @users.export_csv(include_expert_team: true, institutions_subjects: institutions_subjects_exportable)
          send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
        end
        format.xlsx do
          xlsx_filename = "#{(@antenne || @institution).name.parameterize}-#{@users.model_name.human.pluralize.parameterize}.xlsx"
          result = @users.export_xlsx(include_expert_team: true, institutions_subjects: institutions_subjects_exportable)
          send_data result.xlsx.to_stream.read, type: "application/xlsx", filename: xlsx_filename
        end
      end
    end

    def index_better
      @data = annuaire_utilisateurs_hash
      @not_invited_users = not_invited_users

      respond_to do |format|
        format.html
        format.csv do
          result = @users.export_csv(include_expert_team: true, institutions_subjects: institutions_subjects_exportable)
          send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
        end
        format.xlsx do
          xlsx_filename = "#{(@antenne || @institution).name.parameterize}-#{@users.model_name.human.pluralize.parameterize}.xlsx"
          result = @users.export_xlsx(include_expert_team: true, institutions_subjects: institutions_subjects_exportable)
          send_data result.xlsx.to_stream.read, type: "application/xlsx", filename: xlsx_filename
        end
      end
    end

    def send_invitations
      invite_count = 0
      params[:users_ids].split.each do |user_id|
        user = User.find user_id
        next if user.invitation_sent_at.present?
        user.invite!
        invite_count += 1
      end
      if invite_count > 0
        flash[:notice] = t('.invitations_sent', count: invite_count)
      else
        flash[:alert] = t('.invitations_no_sent')
      end
      redirect_to institution_users_path(slug: params[:institution_slug])
    end

    def import; end

    def import_create
      @result = User.import_csv(params.require(:file), institution: @institution)
      if @result.success?
        flash[:table_highlighted_ids] = @result.objects.compact.map(&:id)
        session[:highlighted_antennes_ids] = Antenne.where(advisors: @result.objects).ids
        redirect_to action: :index
      else
        render :import, status: :unprocessable_entity
      end
    end

    private

    def not_invited_users
      if flash[:table_highlighted_ids].present?
        User.where(id: flash[:table_highlighted_ids]).where(invitation_sent_at: nil)
      else
        @users.where(invitation_sent_at: nil)
      end
    end

    def retrieve_antenne
      @antenne = @institution.antennes.find_by(id: params[:antenne_id]) # may be nil
    end

    def retrieve_users
      @users = advisors
        .relevant_for_skills
        .order('antennes.name', 'team_name', 'users.full_name')
        .preload(:antenne, relevant_expert: [:users, :antenne, :experts_subjects])

      if params[:region_id].present?
        @users = @users.in_region(params[:region_id])
      end
    end

    def advisors
      if params[:advisor].present?
        searched_advisor = User.find(params[:advisor])
        flash[:table_highlighted_ids] = [searched_advisor.id]
        advisors = @antenne.advisors.joins(:antenne)
      elsif session[:highlighted_antennes_ids] && @antenne.nil?
        advisors = @institution.advisors.joins(:antenne).where(antenne: { id: session[:highlighted_antennes_ids] })
      else
        advisors = (@antenne || @institution).advisors.joins(:antenne)
      end
      session.delete(:highlighted_antennes_ids)
      advisors
    end

    def annuaire_utilisateurs_hash
      {
        themes: [
          {
            id: 1,
            label: 'Développement commercial',
            subjects: [
              {
                label: 'Faire un point général sur sa stratégie, adapter son activité au nouveau contexte',
                expert_in_subject_count: 1,
                subject_managed_by_other_territorial_level: false, # local, regional, national
                missing_territories: [
                  '22110', '22130'
                ]
              },
              {
                label: "Développer une nouvelle offre de produits ou de services",
                expert_in_subject_count: 0,
                subject_managed_by_other_territorial_level: false, # local, regional, national
                missing_territories: [

                ]
              },
              {
                label: 'Trouver de nouveaux clients et élargir son réseau professionnel',
                expert_in_subject_count: 0,
                subject_managed_by_other_territorial_level: true, # local, regional, national
                missing_territories: [
                  '22340', '22560', '22567', '22564', '22345', '22678', '22456'
                ]
              }
            ],
          },
          {
            id: '2',
            label: 'Ressources humaines',
            subjects: [
              {
                label: 'Recruter un ou plusieurs salariés',
                expert_in_subject_count: 1,
                subject_managed_by_other_territorial_level: true, # local, regional, national
                missing_territories: [

                ]
              }
            ],
          },
          {
            id: 'id',
            label: 'label',
            subjects: [
              {
                label: 'label',
                expert_in_subject_count: 10,
                subject_managed_by_other_territorial_level: 'boolean', # local, regional, national
                missing_territories: [
                  'codes insee manquants'
                ]
              }
            ],
          }
        ],
        antennes: [
          {
            id: 2,
            name: "CCI 22 Côtes d'Armor",
            experts: [
              {
                id: 458,
                name: nil,
                users: [ # penser à ajouter les users qui ont une appartenance à l'antenne via la table user_rights
                  {
                    id: 234,
                    name: 'Amina ABOUKHAR',
                    responsable: 'false',
                    invitation_sent_at: 'Mon, 03 Apr 2023 11:49:15.507415000 CEST +02:00',
                    has_specific_territories: false
                  }
                  ],
                # ici, manque les precisions expert subject (genre "Industrie et commerce de moins de 3 ans")
                has_subject: [true, true, false, false, false] # à voir si pas de soucis d'ordre et de nombre de subjects par themes
              },
              {
                id: 765765,
                name: 'Equipe CFE',
                users: [ # penser à ajouter les users qui ont une appartenance à l'antenne via la table user_rights
                  {
                    id: 6786,
                    name: 'Peter Parker',
                    responsable: true,
                    invitation_sent_at: nil,
                    has_specific_territories: true
                  },
                  {
                    id: 6889,
                    name: 'Clark Kent',
                    responsable: true,
                    invitation_sent_at: 'Mon, 03 Apr 2023 11:49:15.507415000 CEST +02:00',
                    has_specific_territories: false
                  },
                  {
                    id: 9875,
                    name: 'Bruce Bannon',
                    responsable: false,
                    invitation_sent_at: 'Mon, 03 Apr 2023 11:49:15.507415000 CEST +02:00',
                    has_specific_territories: false
                  }
                ],
                has_subject: [false, false, true, true, false] # à voir si pas de soucis d'ordre et de nombre de subjects par themes
              },
            ]
          },
          {
            id: 'id',
            name: 'name',
            experts: [
              {
                id: 'id',
                name: 'name',
                users: [ # penser à ajouter les users qui ont une appartenance à l'antenne via la table user_rights
                  {
                    id: 'id',
                    name: 'name',
                    responsable: 'boolean',
                    invitation_sent_at: 'datetime',
                    has_specific_territories: 'boolean'
                  }
                ],
                has_subject: [true, true, false] # à voir si pas de soucis d'ordre et de nombre de subjects par themes
              },
              {
                id: 'id',
                name: 'name',
                users: [ # penser à ajouter les users qui ont une appartenance à l'antenne via la table user_rights
                  {
                    id: 'id',
                    name: 'name',
                    responsable: 'boolean',
                    invitation_sent_at: 'datetime',
                    has_specific_territories: 'boolean'
                  }
                ],
                has_subject: [true, true, false] # à voir si pas de soucis d'ordre et de nombre de subjects par themes
              }
            ]
          }
        ]
      }
    end
  end
end

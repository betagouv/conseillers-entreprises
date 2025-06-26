module Stats::Needs
  class ThemesFromExternalCooperation
    include ::Stats::Needs::Concerns::Themes

    def needs_themes_base_scope
      needs_base_scope.from_external_cooperation
    end
  end
end

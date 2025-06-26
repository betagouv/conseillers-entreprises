module Stats::Needs
  class ThemesAll
    include ::Stats::Needs::Concerns::Themes

    def needs_themes_base_scope
      needs_base_scope
    end
  end
end

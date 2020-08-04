class RenameLandingAndOptionAttributes < ActiveRecord::Migration[6.0]
  def change
    landing_text_columns = %i[
      meta_title meta_description
      title subtitle logos
      custom_css
      message_under_landing_topics
      partner_url
    ]
    landing_text_columns.each do |col|
      add_column :landings, col, :string
    end
    add_column :landings, :emphasis, :boolean, default: false

    up_only do
      landing_text_columns.each do |col|
        Landing.update_all("#{col} = content->>'#{col}'")
      end
      Landing.update_all("emphasis = CAST(content->>'emphasis' AS boolean)")
    end

    landing_option_text_columns = %i[form_title form_description description_explanation]
    landing_option_text_columns.each do |col|
      add_column :landing_options, col, :string
    end

    up_only do
      landing_option_text_columns.each do |col|
        LandingOption.update_all("#{col} = content->>'#{col}'")
      end
    end
  end
end

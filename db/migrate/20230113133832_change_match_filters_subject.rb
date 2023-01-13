class ChangeMatchFiltersSubject < ActiveRecord::Migration[7.0]
  def change
    create_table :match_filters_subjects, id: false do |t|
      t.belongs_to :match_filter
      t.belongs_to :subject
    end

    MatchFilter.where.not(subject_id: nil).each do |mf|
      mf.subjects << Subject.find_by(id: mf.subject_id)
    end
    remove_reference :match_filters, :subject, index: true, foreign_key: true
  end
end

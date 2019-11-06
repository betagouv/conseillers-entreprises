class AddSubjectToMatches < ActiveRecord::Migration[5.2]
  def change
    add_reference :matches, :subject, foreign_key: true
  end
end

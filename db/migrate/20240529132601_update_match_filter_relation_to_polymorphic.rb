class UpdateMatchFilterRelationToPolymorphic < ActiveRecord::Migration[7.0]
  def up
    add_reference :match_filters, :filtrable_element, polymorphic: true, index: true

    MatchFilter.find_each do |match_filter|
      match_filter.update(filtrable_element: match_filter.antenne)
    end

    change_column_null :match_filters, :filtrable_element_id, false
    remove_reference :match_filters, :antenne, index: true
  end

  def down
    add_reference :match_filters, :antenne, index: true

    MatchFilter.find_each do |match_filter|
      match_filter.update(antenne: match_filter.filtrable_element)
    end

    remove_reference :match_filters, :filtrable_element, polymorphic: true, index: true
  end
end

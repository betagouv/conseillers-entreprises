class CreateStatsViews < ActiveRecord::Migration[7.0]
  def up
    create_view :needs_by_region, sql_definition: Stats::Maps::Maps.needs_by_code_region.to_sql, materialized: true
    create_view :users_by_region, sql_definition: Stats::Maps::Maps.users_by_code_region.to_sql, materialized: true
  end

  def down
    # create_view is supposed to be reversible, but this breaks when using materialized: true
    # See https://github.com/scenic-views/scenic/issues/286#issuecomment-667982418
    drop_view :needs_by_region, materialized: true
    drop_view :users_by_region, materialized: true
  end
end

class AddPgsearch < ActiveRecord::Migration[7.0]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS unaccent'
    execute 'CREATE EXTENSION IF NOT EXISTS pg_trgm'
  end

  def down
    execute 'DROP EXTENSION IF EXISTS unaccent'
    execute 'DROP EXTENSION IF EXISTS pg_trgm'
  end
end

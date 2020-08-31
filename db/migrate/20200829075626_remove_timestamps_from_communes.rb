class RemoveTimestampsFromCommunes < ActiveRecord::Migration[6.0]
  def change
    # default value is only specified so that the migration can rollback
    remove_timestamps :communes, null: false, default: -> { "now()" }
  end
end

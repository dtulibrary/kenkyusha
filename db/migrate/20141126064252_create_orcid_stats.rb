class CreateOrcidStats < ActiveRecord::Migration
  def change
    create_table :orcid_stats do |t|
      ['aau', 'au', 'cbs', 'dtu', 'itu', 'ku', 'ruc', 'sdu'].each do |org|
        t.integer org, :default => 0
      end
      t.timestamps
    end
  end
end

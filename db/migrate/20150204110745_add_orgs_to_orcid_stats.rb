class AddOrgsToOrcidStats < ActiveRecord::Migration
  def change
    change_table :orcid_stats do |t|
      ['ark', 'fak', 'ka', 'sbi', 'ucviden'].each do |code|
        t.integer code, :default => 0
      end
    end
  end
end

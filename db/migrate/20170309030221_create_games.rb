class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.integer :required_voter_count
      t.integer :round, null: false, default: 0
      t.integer :round_grace_minutes, null: false, default: 1
      t.integer :number_of_selections, null: false, default: 2
      t.timestamps
      t.index :created_at, unique: true
    end
  end
end

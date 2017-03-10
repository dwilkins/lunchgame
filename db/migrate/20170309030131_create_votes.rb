class CreateVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :votes do |t|
      t.integer :user_id
      t.integer :restaurant_id
      t.integer :game_id
      t.integer :round

      t.timestamps
    end
  end
end

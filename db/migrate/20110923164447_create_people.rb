class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :access_token

      t.timestamps
    end
  end
end

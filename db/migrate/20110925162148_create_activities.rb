class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :access_token

      t.timestamps
    end
  end
end

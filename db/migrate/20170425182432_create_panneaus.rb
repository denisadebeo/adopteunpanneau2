class CreatePanneaus < ActiveRecord::Migration[5.0]
  def change
    create_table :panneaus do |t|
      t.float :lat
      t.float :long
      t.string :name
      t.boolean :is_ok
      t.string :ville

      t.timestamps
    end
  end
end

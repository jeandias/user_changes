class CreateUserChanges < ActiveRecord::Migration[6.0]
  def change
    create_table :user_changes do |t|
      t.string :field
      t.string :old
      t.string :new
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

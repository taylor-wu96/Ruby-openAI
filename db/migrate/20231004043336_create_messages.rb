class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :role
      t.text :content

      t.timestamps
    end
  end
end

class CreateContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :contacts do |t|
      t.string :uuid
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :phone1
      t.string :phone2
      t.string :email
      t.string :email1
      t.string :email2
      t.string :zip

      t.timestamps
    end
  end
end

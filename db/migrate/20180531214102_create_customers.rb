class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers, id: :uuid do |t|
      t.timestamps
    end
  end
end

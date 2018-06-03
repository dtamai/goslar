class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :customer, type: :uuid, null: false, foreign_key: true
      t.string :status, null: false, default: "new"
      t.jsonb :payload, null: false, default: {}

      t.timestamps
    end
  end
end

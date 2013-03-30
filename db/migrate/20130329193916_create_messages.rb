class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :subject
      t.text :message
      t.integer :sender_id
      t.integer :receiver_id
      t.datetime :senderdelete
      t.datetime :receiverdelete

      t.timestamps
    end
    add_index :messages, :sender_id
    add_index :messages, :receiver_id
  end
end

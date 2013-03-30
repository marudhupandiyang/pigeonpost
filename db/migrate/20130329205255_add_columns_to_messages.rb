class AddColumnsToMessages < ActiveRecord::Migration
  def change
  	add_column :messages, :receiver_read, :datetime, :default => nil
  	add_column :messages, :sender_read, :datetime, :default => nil
  end
end

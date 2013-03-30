class Message < ActiveRecord::Base
  attr_accessible :message, :receiver_id, :receiverdelete, :sender_id, :senderdelete, :subject , :receiver_read ,:sender_read

  belongs_to :sender, :foreign_key => :sender_id ,:class_name => 'User'
  belongs_to :receiver, :foreign_key => :receiver_id  ,:class_name => 'User'

  scope :inbox, where('receiverdelete is null' )

  scope :sentbox, where('senderdelete is  null' )

  scope :unread, where('receiver_read is null' )
  scope :read, where('receiver_read is not null' )

	scope :trash, lambda {|id|
		where("(sender_id = #{id} and senderdelete is not null) or (receiver_id = #{id} and receiverdelete is not null)")
	}


end

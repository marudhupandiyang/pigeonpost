class User < ActiveRecord::Base
  attr_accessible :name

  has_many :received_messages, :foreign_key => :receiver_id ,:class_name => 'Message'
  has_many :sent_messages, :foreign_key => :sender_id ,:class_name => 'Message'
end

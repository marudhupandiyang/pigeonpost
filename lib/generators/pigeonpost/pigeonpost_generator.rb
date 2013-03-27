class PigeonpostGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  attr = ['subject,message,sender,receiver,senderdelete,receiverdelete']

  argument :model_name ,:type => :string , :default => :user
	argument :atributes  ,:type => :array  , :default => attr



end

class PigeonpostGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  @@model_attr = ['subject:text', 'message:text', 'sender:user', 'receiver:user' , 'senderdelete:datetime' ,  'receiverdelete:datetime']


  argument :model_name ,:type => :string , :default => 'user'
	argument :atributes  ,:type => :array  , :default => @@model_attr.join(' ')

	def generate_model
		#check if the class exist
		if defined?(User)

		else
			generate('model',"#{model_name} #{atributes}")
		end

	end



end

class UsersController < ApplicationController

  def set
  	#set the logged in user
  	set_session( User.find(params[:id]) )
  end

  def unset
  	remove_session
  end

  def list
  	render :json => User.select('id,name')
  end

  def create
  	set_session( User.create(:name => params[:name]) )
  end

  def edit
  	user = User.find(params[:id])
  	user.update_attributes(:name => params[:name])
  	set_session(user)
  end


  def destroy
  	User.destory(params[:id])
  	remove_session
  end


  protected

  def set_session(user)
  	session[:id] = user.id
  	session[:name] = user.name
  	redirect_to '/'
  end

  def remove_session
  	reset_session
  	redirect_to '/'
  end

end

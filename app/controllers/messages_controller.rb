class MessagesController < ApplicationController

  # @list all messages
  def index
    @user = User.find(session[:id])
  end

  #create a new message
  def create
    user = User.find(session[:id])

    params[:message][:receiver_read] = nil
    params[:message][:sender_read] =Time.now

    # //remove from from the params to pass to create message
    parent = nil
    unless parent.nil?
      begin
        @message.parent_msg = P2p::Message.find(parent)
      rescue
        @message.parent_msg = nil
      end
    end

    user.sent_messages.create(params[:message])
    render :js => "$('#compose_new_message_modal').modal('hide')"

  end

  #show the message as requested by the id
  def show
    unless request.xhr?
      @user=user
      @message = @user.sent_messages.new
      @inbox = @user.received_messages.inbox
      render :action => :index
      return
    end
    @message=P2p::Message.find(params[:id])
    resp =[]
    while !@message.nil?
      if @message.receiver_id = session[:userid]
        @message.update_attributes(:receiver_status => 1) if @message.receiver_status != 0
        name = @message.sender.user.name
        id = @message.sender.id
      else
        name = @message.receiver.user.name
        id = @message.receiver.id
        return
      end
      dte = @message.created_at.strftime("%d-%h-%C%y %I:%M %p")
      if @message.messagetype == 1 #admin requet
        sub = "Message from Admin"
      elsif @message.messagetype == 2 #admin requet
        sub = "Buy request from " + name
      else
        sub = "Message"
      end
      msg = @message.message
      resp.push( {:name => name , :sub => sub ,:msg => msg ,:dte => dte ,:receiver => id })
      puts @message.inspect + "pp "
      @message = @message.parent_msg
      puts @message.inspect + "p  asdfp "
    end
    render :json => resp
  end

  #destroy the message as requested bye id
  def destroy

    if !params.has_key?(:msgid)
      render :json=> []
      return
    end

    user = User.find(session[:id])

    deleted_messages = []

    time_now = Time.now

    params[:msgid].each do |id|
      if params[:tbl] == 'inbox'
        if user.received_messages.inbox.find(id).update_attributes(:receiverdelete => time_now )
          deleted_messages.push(id)
        end
      elsif params[:tbl] == 'sentbox'
        if user.sent_messages.sentbox.find(id).update_attributes(:senderdelete => time_now )
          deleted_messages.push(id)
        end
      elsif params[:tbl] == 'deletebox'
        msg = P2p::Message.deleted(user).find(id)
        msg.delete
        deleted_messages.push(id)
      end
    end

    unreadcount =  user.received_messages.inbox.unread.count
    # private pub section
    render :json => {:id =>  deleted_messages , :unreadcount => unreadcount}
  end

  #ititate a empyt message record for compose
  def new
    @mesage= user.sent_messages.new
    #render "p2p/messages/compose" ,:message => @message
    #return
  end

  #get the messages as requested bye the data table
  def getbox

    user = User.find(session[:id])

    response={:aaData => []}
    #where to start
    if params.has_key?("iDisplayStart")
      start = (params[:iDisplayStart].to_i / 10) + 1
    else
      start = 1
    end
    #order by the time by default
    order = "created_at desc"
    search = ""
    item = 0
    #if sort is explicitly sennt from the client
    if params.has_key?(:iSortCol_0)
      case params[:iSortCol_0]
      when "3" #based on time column
        order = "created_at " + params[:sSortDir_0]
      when "1" #based on sender column
        #check the table and sent the order by
        if params[:id] == 'inbox'
          order = "sender_id " + params[:sSortDir_0]
        elsif  params[:id] == 'sentbox'
          order = "receiver_id " + params[:sSortDir_0]
       end
      end
    end
    #if the client has request for search
    serach_user = nil
    search_message = ""

    if params.has_key?(:searchq)
      search = params[:searchq]
      if search.index('#') == 0
        begin
          search =  search.slice(1,(search.size-1))
          search_user = User.where("name like '%#{search}%'").first
        rescue
          search_user = nil
        end
      else
        search =  search.slice(1,(search.size-1))
        search_message = " message like '%#{search}%' or subject like '%#{search}%'"
      end
    end
    #find for which items is the request came for
    # and get messages appropiatly
    if params[:box] == 'inbox'
      if search != ""
        if search_user
          messages = user.received_messages.inbox.order(order).where("sender_id=#{search_user.id}").paginate( :page => start ,:per_page => 10)
          message_count = user.received_messages.inbox.where("sender_id=#{search_user.id}").count
        else
          messages = user.received_messages.inbox.order(order).where(search_message).paginate( :page => start ,:per_page => 10)
          message_count = user.received_messages.inbox.where(search_message).count
        end
      else
        messages = user.received_messages.inbox.order(order).paginate( :page => start ,:per_page => 10)
        message_count = user.received_messages.inbox.count
      end
    elsif params[:box] == 'sentbox'
      if search != ''
        if search_user
          messages = user.sent_messages.sentbox.order(order).where("receiver_id=#{search_user.id}").paginate( :page => start,:per_page => 10)
          message_count = user.sent_messages.sentbox.where("receiver_id=#{search_user.id}").count
        else
          messages = user.sent_messages.sentbox.order(order).where(search_message).paginate( :page => start,:per_page => 10)
          message_count = user.sent_messages.sentbox.where(search_message).count
        end
      else
        messages = user.sent_messages.sentbox.order(order).paginate( :page => start,:per_page => 10)
        message_count = user.sent_messages.sentbox.count
      end
    elsif params[:box] == 'deletebox'
      if search !=''
        if search_user
          messages = Message.trash(user.id).order(order).where("sender_id = #{search_user.id} or receiver_id = #{search_user.id} ").paginate( :page => start,:per_page => 10)
          message_count = Message.trash(user.id).where("sender_id = #{search_user.id} or receiver_id = #{search_user.id} ").count
        else
          messages = Message.trash(user.id).order(order).where(search_message).paginate( :page => start,:per_page => 10)
          message_count = Message.trash(user.id).where(search_message).count
        end
      else
        messages = Message.trash(user.id).order(order).paginate( :page => start,:per_page => 10)
        message_count = Message.trash(user.id).count
      end
    end
    # form the response for the datatable
    response[:iTotalRecords] =  message_count
    response[:iTotalDisplayRecords] = message_count
    #form the time to be displayed
    messages.each do |msg|

      #add unread mesage if for color display
      if params[:box] == 'inbox'  and msg.receiver_read == nil
        row_class = 'unread'
      else
        row_class = ''
      end
      #add click trigger for js to display the message
      row_class += ' message_show_trigger'

      response[:aaData].push({
                               "0" => "<input type='checkbox' class='msg_check' msgid='#{msg.id}' >",
                               "1" => msg.sender.name,
                               "2" => msg.subject,
                               "3" => msg.created_at.strftime("%_I:%_S %p"),
                               "DT_RowClass" => row_class
      })
    end
    render :json => response
  end

  def update

    if !params.has_key?(:msgid)
      render :json=> []
      return
    end

    user = User.find(session[:id])

    unread_messages = []

    time_now = Time.now

    params[:msgid].each do |id|
      if user.received_messages.inbox.find(id).update_attributes(:receiver_read => time_now )
        unread_messages.push(id)
      end
    end

    unreadcount =  user.received_messages.inbox.unread.count
    # private pub section
    render :json => {:id =>  unread_messages , :unreadcount => unreadcount}
  end

end

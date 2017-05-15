require 'services/message'

module MessageHelper
  def flash(*args)
    msg = Message.new(*args)
    session[msg.type] = msg.messages
  end

  def clear_messages
    session[:notice] = nil
    session[:error] = nil
  end
end

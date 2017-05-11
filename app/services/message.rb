class Message
  
  attr_accessor :type, :messages
  
  def initialize(type: :info, messages: '')
    @type = type
    @messages = messages
  end
end


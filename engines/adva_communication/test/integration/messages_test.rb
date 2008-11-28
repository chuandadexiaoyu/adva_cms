require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class AnonymousCannotAccessMessagesTest < ActionController::IntegrationTest
  def test_the_anonymous_user_visits_the_inbox
    # go to inbox
    get '/messages'
    
    # the page renders the login screen
    assert_redirected_to login_path(:return_to => 'http://www.example.com/messages')
  end
end

class UserBrowsesMesssageFoldersTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_a_section
    login_as :user
    factory_scenario :user_with_messages
  end
  
  def test_the_user_visits_the_inbox
    # go to inbox
    get '/messages'
    
    # the page renders the inbox
    assert_template 'messages/index'
  end
  
  def test_the_user_visits_the_outbox
    # go to outbox
    get '/messages/outbox'
    
    # the page renders the outbox
    assert_template 'messages/outbox'
  end
  
  def test_the_user_visits_message_new_form
    # go to inbox
    get '/messages'
    
    # clicks a link to create a new message
    clicks_link 'Compose a mail'
    
    # the page renders the new form
    assert_template 'messages/new'
  end

  def test_the_user_reads_a_message
    # go to message
    get "/messages/#{@message_received.id}"
    
    # the page renders the new form
    assert_template 'messages/show'
  end

end

class UserManipulatesMessages < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_a_section
    login_as :user
    factory_scenario :user_with_messages
  end
  
  def test_the_user_deletes_a_message_from_inbox
    # go to inbox
    get '/messages'
    
    # user has received message
    assert @user.messages_received.count == 1
    
    clicks_link 'delete'
    
    assert @user.messages_received.count == 0
  end

  def test_the_user_deletes_a_message_from_outbox
    # go to outbox
    get '/messages/outbox'
    
    # user has sent message
    assert @user.messages_sent.count == 1
    
    clicks_link 'delete'
    
    assert @user.messages_sent.count == 0
  end
    
  def test_the_user_sends_a_message
    johan_mcdoe = Factory :johan_mcdoe
    
    @site.users << johan_mcdoe
    @site.users << @user
    
    # site has two users
    assert @site.users.count == 2
    
    # go to message create form
    get '/messages/new'
    
    # user has sent a message before
    assert @user.messages_sent.count == 1
    
    # johan does not have any received messages yet
    assert johan_mcdoe.messages_received.count == 0
    
    # user fills the message form
    selects       'Johan McDoe', :from => 'message[recipient_id]'
    fills_in      'subject',     :with => 'the message subject'
    fills_in      'body',        :with => 'the message body'
    clicks_button 'Save'
    
    # user has sent one more message
    assert @user.messages_sent.count == 2
    
    # and johan received one message
    assert johan_mcdoe.messages_received.count == 1
  end
  
  # def test_the_user_replies_to_a_message
  #   
  # end
  
  # def test_the_user_marks_a_message_as_unread
  #   
  # end
  
  # def test_the_user_marks_a_message_as_read
  #   
  # end
end
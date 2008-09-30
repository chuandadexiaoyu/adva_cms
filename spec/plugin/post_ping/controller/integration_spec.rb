require File.dirname(__FILE__) + "/../../../spec_helper"

describe "ArticlePingObserver controller integration", :type => :controller do
  controller_name "admin/articles"
  include SpecControllerHelper

  before :each do
    ArticlePingObserver::SERVICES.clear
    @observer = ArticlePingObserver.instance

    @site = Site.create :title => 'site title', :name => 'site name', :host => 'localhost'
    @blog = Blog.create :title => 'blog title', :site => @site
    @article = Article.create :title => 'article title', :body => 'article body', :section => @blog, :author => stub_user

    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true

    @controller.stub!(:current_user).and_return stub_user
    @member_url = "/admin/sites/#{@site.id}/sections/#{@blog.id}/articles/#{@article.id}"
    @published_at_params = {:"published_at(1i)" => "2008", :"published_at(2i)"=>"9", :"published_at(3i)"=>"29"}
  end
  
  def publish_article!
    Article.with_observers('article_ping_observer') do 
      request_to :put, @member_url, :article => @published_at_params
    end
  end

  # it "does not ping a blog service if the article is not published" do
  #   @observer.should_not_receive(:ping_service)
  #   publish_article!
  # end
  # 
  # it "calls the after_save callback if the article is published" do
  #   Article.should_receive(:find).and_return(@article)
  #   @observer.should_receive(:after_save).with(@article)
  #   publish_article!
  # end
  
  it "pings ping-o-matic if the article is published and pom_get is set as a service" do
    ArticlePingObserver::SERVICES << { :url => "http://ping-o-matic.com", :type => :pom_get }
    @pom_get_url = "http://ping-o-matic.com?title=blog title&blogurl=http://test.host/blogs/#{@blog.id}&rssurl=http://test.host/blogs/#{@blog.id}.atom"
    Net::HTTP.should_receive(:get).with URI.parse(URI.escape(@pom_get_url))
    publish_article!
  end

#    it "does a rest_ping ping if article is published and rest_ping is set as service" do
#      ArticlePingObserver::SERVICES << { :url => "http://rest_ping.com/", :type => :rest }
#      Article.should_receive(:find).and_return(@article)
#      @observer.should_receive(:rest_ping).with("http://rest_ping.com/", @article)
#      request_to :put, "/admin/sites/#{@site.id}/sections/#{@blog.id}/articles/#{@article.id}", {:"published_at(1i)" => "2008", :"published_at(2i)"=>"9", :"published_at(3i)"=>"29"}
#    end

#    it "does a xmlrpc_ping ping if article is published and xmlrpc_ping is set as service" do
#      ArticlePingObserver::SERVICES << { :url => "http://xmlrpc_ping.com/", :type => :xmlrpc }
#      Article.should_receive(:find).and_return(@article)
#      @observer.should_receive(:xmlrpc_ping).with("http://xmlrpc_ping.com/", @article)
#      request_to :put, "/admin/sites/#{@site.id}/sections/#{@blog.id}/articles/#{@article.id}", {:"published_at(1i)" => "2008", :"published_at(2i)"=>"9", :"published_at(3i)"=>"29"}
#    end
end
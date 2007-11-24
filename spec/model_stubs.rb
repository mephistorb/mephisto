ModelStubbing.define_models do
  # only put minimal, core models in here if specs require interaction
  # with lots of models
  
  time 2007, 6, 15
  
  model Site do
    stub :title => "Mephisto", :host => 'test.host', :filter => 'textile_filter', :approve_comments => false,
      :comment_age => 30, :timezone => "America/New_York", :articles_per_page => 15, :permalink_style => ":year/:month/:day/:permalink",
      :tag_path => 'tags', :search_path => 'search', :current_theme_path => 'current'
  end
  
  model User do
    stub :login => 'quentin', :email => 'quentin@example.com', :filter => 'textile_filter', :token => 'quentintoken', :admin => true,
      :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :crypted_password => '00742970dc9e6319f8019fd54864d3ea740f04b1'
  end
  
  # model Article do
  #   stub :title => 'foobar'
  # end
end
require 'ostruct'
require File.join(RAILS_ROOT, '/test/mocks/test/convert/word_press/category')
module WordPress
  class Post
    POSTS = [
      OpenStruct.new(
        'ID' => '1',
        'post_author' => '1',
        'post_date' => '<%= 6.days.ago.to_s(:db) %>',
        'post_content' => 'Welcome to WordPress! This is some content',
        'post_title' => 'Welcome',
        'post_excerpt' => 'Wordpress introduction',
        'post_status' => 'publish',
        'comment_status' => 'open',
        'post_password' => '',
        'post_name' => 'welcome',
        'post_modified' => '<%= 6.days.ago.to_s(:db) %>',
        'categories' => [WordPress::Category.find(0)]
      ),
      OpenStruct.new(
        'ID' => '2',
        'post_author' => '1',
        'post_date' => '<%= 5.days.ago.to_s(:db) %>',
        'post_content' => 'Life is dandy and so fort',
        'post_title' => 'Stuff to think about',
        'post_excerpt' => '',
        'post_status' => 'publish',
        'comment_status' => 'closed',
        'post_password' => '',
        'post_name' => 'stuff-to-think-about',
        'post_modified' => '<%= 4.days.ago.to_s(:db) %>',
        'categories' => [WordPress::Category.find(1)]
      ),
      OpenStruct.new(
        'ID' => '3',
        'post_author' => '1',
        'post_date' => '<%= 5.days.ago.to_s(:db) %>',
        'post_content' => 'Two men walk into a bar...*laughter*',
        'post_title' => 'A Joke Of Old',
        'post_excerpt' => '',
        'post_status' => 'publish',
        'comment_status' => 'open',
        'post_password' => '',
        'post_name' => 'a-joke-of-old',
        'post_modified' => '<%= 4.days.ago.to_s(:db) %>',
        'categories' => [WordPress::Category.find(0)]
      ),
      OpenStruct.new(
        'ID' => '4',
        'post_author' => '1',
        'post_date' => '<%= 5.days.ago.to_s(:db) %>',
        'post_content' => 'My grand thesis that will change the world.. Work in progress',
        'post_title' => 'World Peace',
        'post_excerpt' => 'Shibby',
        'post_status' => 'draft',
        'comment_status' => 'open',
        'post_password' => '',
        'post_name' => 'world-peace',
        'post_modified' => '<%= 4.days.ago.to_s(:db) %>',
        'categories' => [WordPress::Category.find(2)]
      
      ),
      OpenStruct.new(
        'ID' => '5',
        'post_author' => '1',
        'post_date' => '<%= 5.days.ago.to_s(:db) %>',
        'post_content' => 'The author of this page is searching for the Holy Grail',
        'post_title' => 'About the author',
        'post_excerpt' => '',
        'post_status' => 'static',
        'comment_status' => 'open',
        'post_password' => 'thanos',
        'post_name' => 'about-the-author',
        'post_modified' => '<%= 4.days.ago.to_s(:db) %>',
        'categories' => [WordPress::Category.find(2)]

       )
    ]

    def self.find(arg)
      if arg == :all then
        POSTS
      else
        # assume we're mocking find(id), so subtract one to get the array index
        POSTS[arg.to_i - 1]
      end
    end
  end
end
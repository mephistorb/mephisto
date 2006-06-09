require 'ostruct'

module Typo
  class Article
    ARTICLES = [
      OpenStruct.new(
        'user_id' => 1,
        'title' => 'article one',
        'excerpt' => 'This is the short bit',
        'body' => 'This is the long bit',
        'created_at' => Time.now,
        'updated_at' => Time.now,
        'published_at' => Time.now,
        'categories' => [OpenStruct.new(:name => 'foo')]
      ),
      OpenStruct.new(
        'user_id' => 2,
        'title' => 'article two',
        'excerpt' => 'This is the short bit 2',
        'body' => 'This is the long bit 2',
        'created_at' => Time.now,
        'updated_at' => Time.now,
        'published_at' => Time.now,
        'categories' => [OpenStruct.new(:name => 'foo')]
      )      
    ]
    
    def self.find(arg)
      if arg == :all then
        ARTICLES
      else
        # assume we're mocking find(id), so subtract one to get the array index
        ARTICLES[arg - 1]
      end
    end
  end
end
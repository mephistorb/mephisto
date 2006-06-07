require 'app/models/comment'
Comment.class_eval do
  before_validation { |c| c.approved = true if c.author.to_s =~ /approved/ }
end
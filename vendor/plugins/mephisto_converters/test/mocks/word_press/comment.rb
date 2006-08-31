require 'ostruct'
module WordPress
  class Comment
    COMMENTS = [
      OpenStruct.new(
        'comment_ID' => '1',
        'comment_post_ID' => '1',
        'comment_author' => 'A Fan of Yours',
        'comment_author_email' => 'superfan@example.com',
        'comment_author_url' => '',
        'comment_author_IP' => '256.128.0.66',
        'comment_date' => '<%= 6.days.ago.to_s(:db) %>',
        'comment_content' => 'I thought you were very funny',
        'comment_approved' => '1',
        'user_id' => ''
      ),
      OpenStruct.new(
        'comment_ID' => '2',
        'comment_post_ID' => '2',
        'comment_author' => 'sports poker',
        'comment_author_email' => 'winsomecash@example.com',
        'comment_author_url' => 'http://www.example.com/',
        'comment_author_IP' => '192.168.1.1',
        'comment_date' => '<%= 2.days.ago.to_s(:db) %>',
        'comment_content' => 'poker',
        'comment_approved' => 'spam',
        'user_id' => ''
      ),
      OpenStruct.new(
        'comment_ID' => '3',
        'comment_post_ID' => '1',
        'comment_author' => 'John Doe',
        'comment_author_email' => 'jdoe@example.com',
        'comment_author_url' => 'http://www.example.com/jdoe/',
        'comment_author_IP' => '192.168.1.66',
        'comment_date' => '<%= 2.days.ago.to_s(:db) %>',
        'comment_content' => 'I think you misspelled misspell',
        'comment_approved' => '0',
        'user_id' => ''
      ),
      OpenStruct.new(
        'comment_ID' => '4',
        'comment_post_ID' => '3',
        'comment_author' => 'Codeaholic',
        'comment_author_email' => 'codeaholic@example.com',
        'comment_author_url' => 'http://example.com/coderz/',
        'comment_author_IP' => '192.168.42.42',
        'comment_date' => '<%= 3.days.ago.to_s(:db) %>',
        'comment_content' => 'Do you like to rock?',
        'comment_approved' => '1',
        'user_id' => ''
      ),
      OpenStruct.new(
        'comment_ID' => '5',
        'comment_post_ID' => '3',
        'comment_author' => 'quentin',
        'comment_author_email' => 'quentin@example.com',
        'comment_author_url' => 'http://www.example.com/u/quentin/',
        'comment_author_IP' => '127.0.0.1',
        'comment_date' => '<%= 2.days.ago.to_s(:db) %>',
        'comment_content' => 'Yeah!',
        'comment_approved' => '1',
        'user_id' => '1'
        )
    ]
    def self.find(arg)
      if arg == :all then
        COMMENTS
      else
        # assume we're mocking find(id), so subtract one to get the array index
        COMMENTS[arg - 1]
      end
    end

    def self.find_by_post(post)
      id = ( post.class == WordPress::Post ) ? post.ID : post
      COMMENTS.inject([]) do |right_comments, ostruct_comment|
        if ostruct_comment.comment_post_ID.to_i == id
          right_comments << ostruct_comment
        else
          right_comments
        end
      end
    end
  end
end
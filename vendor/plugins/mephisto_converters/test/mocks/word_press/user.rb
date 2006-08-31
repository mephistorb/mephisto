require 'ostruct'
module WordPress
  class User
    USERS = [
      OpenStruct.new(
        'ID' => '1',
        'user_login' => 'quentin',
        'user_email' => 'quentin@example.com',
        'user_url' => 'http://www.example.com/u/quentin/',
        'display_name' => 'Quentin Hapsburg'
      ),
      OpenStruct.new(
        'ID' => '2',
        'user_login' => 'arthur',
        'user_email' => 'arthur@example.com',
        'user_url' => 'http://www.example.com/u/arthur/',
        'display_name' => 'Arthur Miller'
      ),
      OpenStruct.new(
        'ID' => '3',
        'user_login' => 'aaron',
        'user_email' => 'aaron@example.com',
        'user_url' => 'http://www.example.com/u/aaron/',
        'display_name' => 'Aaron Spelling'
      )
    ]

    def self.find(arg)
      if arg == :all then
        USERS
      else
        # assume we're mocking find(id), so subtract one to get the array index
        USERS[arg.to_i - 1]
      end
    end
  end
end
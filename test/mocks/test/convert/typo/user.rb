require 'ostruct'
module Typo
  class User
    USERS = [
      OpenStruct.new('email' => 'typo1@example.com', 'login' => 'fred'),
      OpenStruct.new('email' => 'typo2@example.com', 'login' => 'joe')
    ]
    
    def self.find(arg)
      if arg == :all then
        USERS
      else
        # assume we're mocking find(id), so subtract one to get the array index
        USERS[arg - 1]
      end
    end
  end
end
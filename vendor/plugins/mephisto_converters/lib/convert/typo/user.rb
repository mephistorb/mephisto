module Typo
  class User < ActiveRecord::Base
    establish_connection configurations['typo']
  end
end

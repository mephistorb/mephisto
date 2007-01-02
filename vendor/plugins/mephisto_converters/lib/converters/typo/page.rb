module Typo
  class Page < Content
    establish_connection configurations['typo']
    belongs_to :user
    def comments
      []
    end
  end
end

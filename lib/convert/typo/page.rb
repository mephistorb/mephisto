module Typo
  class Page < Content
    establish_connection configurations['typo']
  end
end

module MovableTypeStructs
  class Trackback < ActionWebService::Struct
    member :pingTitle, :string
    member :pingURL,   :string
    member :pingIP,    :string
  end
end
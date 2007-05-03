module MovableTypeStructs
  class Post < ActionWebService::Struct
    member :dateCreated,    :time #ISO.8601
    member :userid,         :string
    member :postid,         :string
    member :title,          :string
  end
end

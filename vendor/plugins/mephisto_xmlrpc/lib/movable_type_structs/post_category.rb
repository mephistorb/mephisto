module MovableTypeStructs
  class PostCategory < ActionWebService::Struct
    member :categoryId,    :string
    member :categoryName,  :string
    member :isPrimary,     :bool 
  end
end

module MovableTypeStructs
  class Category < ActionWebService::Struct
    member :categoryId,    :string
    member :categoryName,  :string
  end
end

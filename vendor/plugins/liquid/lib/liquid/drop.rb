module Liquid
  
  # A drop in liquid is a class which allows you to to export DOM like things to liquid
  # Methods of drops are callable. 
  # The main use for liquid drops is the implement lazy loaded objects. 
  # If you would like to make data available to the web designers which you don't want loaded unless needed then 
  # a drop is a great way to do that
  #
  # Example:
  #
  # class ProductDrop < Liquid::Drop
  #   def top_sales
  #      Shop.current.products.find(:all, :order => 'sales', :limit => 10 )
  #   end
  # end
  #  
  # tmpl = Liquid::Template.parse( ' {% for product in product.top_sales %} {{ product.name }} {%endfor%} '  )
  # tmpl.render('product' => ProductDrop.new ) # will invoke top_sales query. 
  #
  # Your drop can either implement the methods sans any parameters or implement the before_method(name) method which is a 
  # catch all
  class Drop

    # Catch all for the method 
    def before_method(method)
      nil
    end
    
    # called by liquid to invoke a drop
    def invoke_drop(method)      
      result = before_method(method)
      result ||= send(method.to_sym) if respond_to?(method.to_sym)
      result
    end
    
    def has_key?(name)
      true
    end

    alias :[] :invoke_drop
  end
  
end
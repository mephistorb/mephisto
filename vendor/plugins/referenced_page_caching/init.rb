ActionController::Base.send :include, Caboose::Caching::ReferencedCachingSystem
ActiveRecord::Base.class_eval do
  def referenced_cache_key
    "[#{[id, self.class.name] * ':'}]"
  end
end
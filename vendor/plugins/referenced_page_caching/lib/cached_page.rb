# Represents a cached page in the database.  Has one or more references that expire it.
# Sample schema:
# 
#   create_table :cached_pages, :force => true do |t|
#     t.column :url,        :string, :limit => 255
#     t.column :references, :text
#     t.column :updated_at, :datetime
#   end
# 
class CachedPage < ActiveRecord::Base
  validates_uniqueness_of :url

  class << self
    # Finds all pages that this record refers to
    #
    #   CachedPage.find_by_reference  Foo.find(15)
    #   CachedPage.find_by_references *Foo.find(15,16,17)
    def find_by_references(*references)
      find_by_reference_keys *references.collect { |r| [r.class.name, r.id] }
    end
    alias find_by_reference find_by_references

    # Finds all pages that these records refer to
    #
    #   CachedPage.find_by_reference_keys ['Foo', 15], ['Bar', 17]
    #
    def find_by_reference_keys(*array_of_keys)
      find :all, :conditions => [array_of_keys.collect { |r| "#{self.connection.quote_column_name('references')} LIKE ?" } * ' OR ', array_of_keys.collect { |r| "%[#{[r.last, r.first] * ':'}]%" }]
    end

    # Finds all pages that this record refers to
    #
    #   CachedPage.find_by_reference_key 'Foo', 15
    #
    def find_by_reference_key(class_name, record_id)
      find_by_reference_keys [class_name, record_id]
    end

    # Clears all references from this page
    def expire_pages(pages)
      delete_all "id IN (#{pages.collect { |p| quote(p.id) }.join(', ')})" unless pages.empty?
    end
    
    def create_by_url(url, references)
      page = find_by_url(url) || new(:url => url)
      page.references = references.compact.flatten.uniq.collect { |r| r.referenced_cache_key }.join
      page.save
    end
  end
end
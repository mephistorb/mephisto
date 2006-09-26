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
  @@current_scope_conditions = { :find => { :conditions => "cleared_at IS NULL OR cleared_at < updated_at" } }
  cattr_reader :current_scope_conditions
  belongs_to :site
  validates_uniqueness_of :url, :scope => :site_id

  class << self
    def with_current_scope(&block)
      with_scope current_scope_conditions, &block
    end

    def find_current(*args)
      with_current_scope { find(*args) }
    end

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
      find_current :all, :conditions => ["(#{array_of_keys.collect { |r| "#{connection.quote_column_name('references')} LIKE ?" } * ' OR '})", *array_of_keys.collect { |r| "%[#{[r.last, r.first] * ':'}]%" }]
    end

    # Finds all pages that this record refers to
    #
    #   CachedPage.find_by_reference_key 'Foo', 15
    #
    def find_by_reference_key(class_name, record_id)
      find_by_reference_keys [class_name, record_id]
    end

    # Clears all references from this page
    def expire_pages(site, pages)
      update_all ['cleared_at = ?', Time.now.utc], ["site_id = ? and id IN (?)", site.id, pages.collect(&:id)] unless pages.empty?
    end
    
    def create_by_url(site, url, references)
      returning find_or_initialize_by_site_id_and_url(site.id, url) do |page|
        [:compact!, :flatten!, :uniq!].each { |m| references.send m }
        references.collect! { |r| r.respond_to?(:referenced_cache_key) ? r.referenced_cache_key : r }
        page.references = references.join
        page.cleared_at = nil
        page.save
      end
    end
  end
end
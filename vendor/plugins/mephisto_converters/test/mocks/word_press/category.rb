require 'ostruct'
module WordPress
  class Category
    CATEGORIES = [
      OpenStruct.new(
        'cat_ID' => '1',
        'cat_name' => 'Unsorted',
        'category_nicename' => 'unsorted',
        'category_parent' => '0'
      ),
      OpenStruct.new(
        'cat_ID' => '2',
        'cat_name' => 'Programming',
        'category_nicename' => 'programming',
        'category_parent' => '0'
      ),
      OpenStruct.new(
        'cat_ID' => '3',
        'cat_name' => 'Humour',
        'category_nicename' => 'humour',
        'category_description' => '',
        'category_parent' => '0'
      ),
      OpenStruct.new(
        'cat_ID' => '4',
        'cat_name' => 'Ruby',
        'category_nicename' => 'ruby',
        'category_parent' => '2'
      )
    ]

    def self.find(arg)
     if arg == :all then
       CATEGORIES
     else
       # assume we're mocking find(id), so subtract one to get the array index
       CATEGORIES[arg - 1]
     end
    end

    def self.find_by_cat_ID(id)
     category = nil
     CATEGORIES.each do |ostruct_cat|
       if ostruct_cat.cat_ID.to_i == id.to_i
         category = ostruct_cat
       end
     end
     category
    end

  end
end
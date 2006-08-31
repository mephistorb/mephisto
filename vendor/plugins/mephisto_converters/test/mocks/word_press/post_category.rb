require 'ostruct'
module WordPress
  class PostCategory
    POST_CATEGORIES = [
      OpenStruct.new(
        'rel_id' => '1',
        'post_id' => '1',
        'category_id' => '1'
      ),
      OpenStruct.new(
        'rel_id' => '2',
        'post_id' => '1',
        'category_id' => '3'
      ),
      OpenStruct.new(
        'rel_id' => '3',
        'post_id' => '2',
        'category_id' => '2'
      ),
      OpenStruct.new(
        'rel_id' => '4',
        'post_id' => '2',
        'category_id' => '4'
      ),
      OpenStruct.new(
        'rel_id' => '5',
        'post_id' => '3',
        'category_id' => '2'
      ),
      OpenStruct.new(
        'rel_id' => '6',
        'post_id' => '3',
        'category_id' => '3'
      ),
      OpenStruct.new(
        'rel_id' => '7',
        'post_id' => '3',
        'category_id' => '4'
      ),
      OpenStruct.new(
        'rel_id' => '8',
        'post_id' => '4',
        'category_id' => '1'
      ),
      OpenStruct.new(
        'rel_id' => '9',
        'post_id' => '5',
        'category_id' => '1'
      )
    ]

    def self.find(arg)
      if arg == :all then
        POST_CATEGORIES
      else
        # assume we're mocking find(id), so subtract one to get the array index
        POST_CATEGORIES[arg - 1]
      end
    end

    def self.find_all_by_post_id(post)
      id = post
      POST_CATEGORIES.inject([]) do |category_ids, relation|
        if relation.post_id.to_i == id.to_i
          category_ids << relation
        else
          category_ids
        end
      end
    end
  end
end
class MovableTypeApi < ActionWebService::API::Base
  inflect_names false

  # Movable Type Programatic interface
  # see: <http://www.movabletype.org/mt-static/docs/mtmanual_programmatic.html>
  # supportedTextFilters has already been there!
  # - Moritz Angermann
  #
  # mt.getRecentPostTitles
  # Description: Returns a bandwidth-friendly list of the most recent posts in the system.
  # Parameters: String blogid, String username, String password, int numberOfPosts
  # Return value: on success, array of structs containing ISO.8601 dateCreated, String userid, String postid, String title; on failure, fault
  # Notes: dateCreated is in the timezone of the weblog blogid
  # Reference: <http://www.sixapart.com/developers/xmlrpc/movable_type_api/mtgetrecentposttitles.html>

  #api_method :getRecentPostTitles,
  #  :expects => [ {:blogid => :string}, {:username => :string}, {:password => :string}, {:numberOfPosts => :int} ],
  #  :returns => [[MovableTypeStructs::Post]]

  # mt.getCategoryList
  # Description: Returns a list of all categories defined in the weblog.
  # Parameters: String blogid, String username, String password
  # Return value: on success, an array of structs containing String categoryId and String categoryName; on failure, fault.
  # Reference: <http://www.sixapart.com/developers/xmlrpc/movable_type_api/mtgetcategorylist.html>
  api_method :getCategoryList,
    :expects => [ {:blogid => :string}, {:username => :string}, {:password => :string} ],
    :returns => [[MovableTypeStructs::Category]]

  # mt.getPostCategories
  # Description: Returns a list of all categories to which the post is assigned.
  # Parameters: String postid, String username, String password
  # Return value: on success, an array of structs containing String categoryName, String categoryId, and boolean isPrimary; on failure, fault.
  # Notes: isPrimary denotes whether a category is the post's primary category.
  # Reference: <http://www.sixapart.com/developers/xmlrpc/movable_type_api/mtgetpostcategories.html>
  api_method :getPostCategories,
    :expects => [ {:postid => :string}, {:username => :string}, {:password => :string} ],
    :returns => [[MovableTypeStructs::Category]]

  # mt.setPostCategories
  # Description: Sets the categories for a post.
  # Parameters: String postid, String username, String password, array categories
  # Return value: on success, boolean true value; on failure, fault
  # Notes: the array categories is an array of structs containing String categoryId and boolean isPrimary. Using isPrimary to set the primary category is optional--in the absence of this flag, the first struct in the array will be assigned the primary category for the post.
  # Reference: <http://www.sixapart.com/developers/xmlrpc/movable_type_api/mtsetpostcategories.html>
  api_method :setPostCategories,
    :expects => [ {:postid => :string}, {:username => :string}, {:password => :string}, {:categories => [MovableTypeStructs::PostCategory]} ],
    :returns => [:bool]

  # mt.supportedMethods
  # Description: Retrieve information about the XML-RPC methods supported by the server.
  # Parameters: none
  # Return value: an array of method names supported by the server.
  # Reference: <http://www.sixapart.com/developers/xmlrpc/movable_type_api/mtsupportedMethods.html>

  api_method :supportedMethods,
    :expects => [],
    :returns => [[:string]]

  # mt.supportedTextFilters
  # Description: Retrieve information about the text formatting plugins supported by the server.
  # Parameters: none
  # Return value: an array of structs containing String key and String label. key is the unique string identifying a text formatting plugin, and label is the readable description to be displayed to a user. key is the value that should be passed in the mt_convert_breaks parameter to newPost and editPost.
  # Reference: <http://www.sixapart.com/developers/xmlrpc/movable_type_api/mtsupportedtextfilters.html>

  api_method :supportedTextFilters,
    :expects => [],
    :returns => [[MovableTypeStructs::TextFilter]]

  # mt.getTrackbackPings
  # Description: Retrieve the list of TrackBack pings posted to a particular entry. This could be used to programmatically retrieve the list of pings for a particular entry, then iterate through each of those pings doing the same, until one has built up a graph of the web of entries referencing one another on a particular topic.
  # Parameters: String postid
  # Return value: an array of structs containing String pingTitle (the title of the entry sent in the ping), String pingURL (the URL of the entry), and String pingIP (the IP address of the host that sent the ping).
  # Reference: <http://www.sixapart.com/developers/xmlrpc/movable_type_api/mtgettrackbackpings.html>

  # api_method :getTrackbackPings,
  #   :expects => [ {:postid => :string} ],
  #   :returns => [[MovableTypeStructs::Trackback]]

  # mt.publishPost
  # Description: Publish (rebuild) all of the static files related to an entry from your weblog. Equivalent to saving an entry in the system (but without the ping).
  # Parameters: String postid, String username, String password
  # Returns value: on success, boolean true value; on failure, fault
  # Reference: <http://www.sixapart.com/developers/xmlrpc/movable_type_api/mtpublishpost.html>

  #api_method :publishPost,
  #  :expects => [ {:postid => :string}, {:username => :string}, {:password => :string} ],
  #  :returns => [:bool]
end

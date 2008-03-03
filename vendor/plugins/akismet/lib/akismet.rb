require 'net/http'
require 'uri'
  
# Akismet
#
# Author:: David Czarnecki
# Copyright:: Copyright (c) 2005 - David Czarnecki
# License:: BSD
#
# rewritten to be more rails-like
class Akismet
  
  cattr_accessor :valid_responses, :normal_responses
  attr_accessor :proxy_port, :proxy_host
  attr_reader :last_response

  @@valid_responses  = Set.new(['false', ''])
  @@normal_responses = @@valid_responses.dup << 'true'
  STANDARD_HEADERS = {
    'User-Agent'   => 'Mephisto/' << Mephisto::Version::STRING,
    'Content-Type' => 'application/x-www-form-urlencoded'
  }
  
  # Create a new instance of the Akismet class
  #
  # api_key 
  #   Your Akismet API key
  # blog 
  #   The blog associated with your api key
  def initialize(api_key, blog)
    @api_key      = api_key
    @blog         = blog
    @verified_key = false
    @proxy_port   = nil
    @proxy_host   = nil
  end

  # Returns <tt>true</tt> if the API key has been verified, <tt>false</tt> otherwise
  def verified?
    (@verified_key ||= verify_api_key) != :false
  end

  # This is basically the core of everything. This call takes a number of arguments and characteristics about the submitted content and then returns a thumbs up or thumbs down. Almost everything is optional, but performance can drop dramatically if you exclude certain elements.
  #
  # user_ip (required)
  #    IP address of the comment submitter.
  # user_agent (required)
  #    User agent information.
  # referrer (note spelling)
  #    The content of the HTTP_REFERER header should be sent here.
  # permalink
  #    The permanent location of the entry the comment was submitted to.
  # comment_type
  #    May be blank, comment, trackback, pingback, or a made up value like "registration".
  # comment_author
  #    Submitted name with the comment
  # comment_author_email
  #    Submitted email address
  # comment_author_url
  #    Commenter URL.
  # comment_content
  #    The content that was submitted.
  # Other server enviroment variables
  #    In PHP there is an array of enviroment variables called $_SERVER which contains information about the web server itself as well as a key/value for every HTTP header sent with the request. This data is highly useful to Akismet as how the submited content interacts with the server can be very telling, so please include as much information as possible.
  def comment_check(options = {})
    !@@valid_responses.include?(call_akismet('comment-check', options))
  end
  
  # This call is for submitting comments that weren't marked as spam but should have been. It takes identical arguments as comment check.
  # The call parameters are the same as for the #commentCheck method.
  def submit_spam(options = {})
    call_akismet('submit-spam', options)
  end
  
  # This call is intended for the marking of false positives, things that were incorrectly marked as spam. It takes identical arguments as comment check and submit spam.
  # The call parameters are the same as for the #commentCheck method.
  def submit_ham(options = {})
    call_akismet('submit-ham', options)
  end

  protected
    # Internal call to Akismet. Prepares the data for posting to the Akismet service.
    #
    # akismet_function
    #   The Akismet function that should be called
    # user_ip (required)
    #    IP address of the comment submitter.
    # user_agent (required)
    #    User agent information.
    # referrer (note spelling)
    #    The content of the HTTP_REFERER header should be sent here.
    # permalink
    #    The permanent location of the entry the comment was submitted to.
    # comment_type
    #    May be blank, comment, trackback, pingback, or a made up value like "registration".
    # comment_author
    #    Submitted name with the comment
    # comment_author_email
    #    Submitted email address
    # comment_author_url
    #    Commenter URL.
    # comment_content
    #    The content that was submitted.
    # Other server enviroment variables
    #    In PHP there is an array of enviroment variables called $_SERVER which contains information about the web server itself as well as a key/value for every HTTP header sent with the request. This data is highly useful to Akismet as how the submited content interacts with the server can be very telling, so please include as much information as possible.  
    def call_akismet(akismet_function, options = {})
      http = Net::HTTP.new("#{@api_key}.rest.akismet.com", 80, @proxy_host, @proxy_port)
      data = URI.escape(options.update(:blog => @blog).inject([]) { |data, opt| data << '%s=%s' % opt } * '&')              
      resp, @last_response = http.post("/1.1/#{akismet_function}", data, STANDARD_HEADERS)
      @last_response
    end

    # Call to check and verify your API key. You may then call the #hasVerifiedKey method to see if your key has been validated.
    def verify_api_key
      http = Net::HTTP.new('rest.akismet.com', 80, @proxy_host, @proxy_port)
      resp, data = http.post('/1.1/verify-key', "key=#{@api_key}&blog=#{@blog}", STANDARD_HEADERS)
      @verified_key = (data == "valid") ? true : :false
    end
end
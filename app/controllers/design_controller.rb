class DesignController < ApplicationController
  def index
    @resource = Resource.new
  end
end

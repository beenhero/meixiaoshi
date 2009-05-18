class TagsController < ApplicationController
  
  def index
    @tags = Service.tag_counts
  end
end
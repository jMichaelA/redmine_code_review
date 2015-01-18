class ReviewController < ApplicationController
  unloadable


  def index
    @reviews = Comment.all
  end
end

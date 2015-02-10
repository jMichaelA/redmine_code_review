class ReviewsController < ApplicationController
  unloadable

  def index
    @reviews = Review.all
  end

  def show

  end

  def new

  end

  # TODO Uncomment and implement these when needed
  # def add_comment
  # end
  #
  # def delete_comment
  # end
  #
  # def approve
  # end
  #
  # def reject
  # end

end

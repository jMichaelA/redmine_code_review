class ReviewsController < ApplicationController
  unloadable

  layout 'base'
  before_filter :find_project, :authorize
  menu_item :redmine_code_review

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
private
  def find_project
    @project=Project.find(params[:id])
  end

end

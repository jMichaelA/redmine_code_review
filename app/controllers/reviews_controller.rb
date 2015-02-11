class ReviewsController < ApplicationController
  unloadable

  layout 'base'
  before_filter :find_project # TODO (jchristensen) Add before_filter :authorize when ready
  menu_item :redmine_code_review

  helper RepositoriesHelper

  def index

  end

  def show
    @review = Review.find(params[:review])
    @changeset = Changeset.find(@review.changeset_id)
    @repository = Repository.find(@changeset.repository_id)
    
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
    @project = Project.find(params[:id])

  end

end

class ReviewsController < ApplicationController
  unloadable

  layout 'base'
  before_filter :find_project # TODO (jchristensen) Add before_filter :authorize when ready
  menu_item :redmine_code_review

  helper RepositoriesHelper
  helper ReviewHelper

  def index
    @reviews = Review.all()
    @review_column_names = Review.column_names()
  end

  def show
    @review = Review.find(params[:review_id])
    @changeset = Changeset.find(@review.changeset_id)
    @repository = Repository.find(@changeset.repository_id)

    if params[:path]
      diff
    end

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

  def diff
    @path = params[:path]
    @rev = params[:rev]
    if params[:format] == 'diff'
      @diff = @repository.diff(@path, @rev, @rev_to)
      (review_show_error_not_found; return) unless @diff
      filename = "changeset_r#{@rev}"
      filename << "_r#{@rev_to}" if @rev_to
      send_data @diff.join, :filename => "#{filename}.diff",
                :type => 'text/x-patch',
                :disposition => 'attachment'
    else
      @diff_type = params[:type] || User.current.pref[:diff_type] || 'inline'
      @diff_type = 'inline' unless %w(inline sbs).include?(@diff_type)

      # Save diff type as user preference
      if User.current.logged? && @diff_type != User.current.pref[:diff_type]
        User.current.pref[:diff_type] = @diff_type
        User.current.preference.save
      end
      @cache_key = "reviews/show/#{@review.id}/" + Digest::MD5.hexdigest("#{@path}-#{@rev}-#{@rev_to}-#{@diff_type}-#{current_language}")
      unless read_fragment(@cache_key)
        @diff = @repository.diff(@path, @rev, @rev_to)
        review_show_error_not_found unless @diff
      end

      @changeset = @repository.find_changeset_by_name(@rev)
      @changeset_to = @rev_to ? @repository.find_changeset_by_name(@rev_to) : nil
      @diff_format_revisions = @repository.diff_format_revisions(@changeset, @changeset_to)
    end
  end

private
  def find_project
    @project = Project.find(params[:id])
  end

  def review_show_error_not_found
    render_error :message => l(:error_scm_not_found), :status => 404
  end

end

class TagsController < ApplicationController
  before_filter :ensure_admin, only: [:index]

  def index
    @start_date = default_start_date(params[:start_date])
    @end_date = default_end_date(params[:end_date])
    # @stories = Story.where(:tweeted_at => @start_date..@end_date)
    # @story_tags = Story.where(:tweeted_at => @start_date..@end_date)
    @tags = Tag.all
    @stories_within_range = Story.where(:tweeted_at => @start_date..@end_date)
    @unique_handles = @stories_within_range.group_by { |h| h.twitter_handle }
  end

  def show
    @tag = Tag.find(params[:id])
    @stories = @tag.stories.within_past_month.ranked.page(params[:page]).limit(50)

    #make sure the newest freinly_id is being used
    if request.path != tag_path(@tag)
      redirect_to tag_path(@tag), status: :moved_permanently
    end

    #ensue they always go to the events index
    if @tag.id == 1
      redirect_to events_path, status: :moved_permanently
    end

  end

  def default_start_date(string)
    return Date.current - 1.month if string.nil? 
    Date.parse(string)
  end


  def default_end_date(string)
    return Date.current if string.nil?
    Date.parse(string)
  end

private

  def ensure_admin
    if current_user.nil? || !current_user.admin?
      redirect_to root_url
    end
  end




end
class Review < ActiveRecord::Base

  scope :visible, lambda {|*args|
                  includes(:project).where(Review.visible_condition(args.shift || User.current, *args))
                }


  belongs_to :user
  belongs_to :changeset
  belongs_to :project
  belongs_to :priority, :class_name => 'IssuePriority', :foreign_key => 'priority_id'
  has_many :review_participants
  has_many :review_files

  validates_presence_of :changeset_id, :project_id, :priority_id

  acts_as_watchable

  alias_attribute :creator, :user

  def comment(text)
    #Nothing here yet
  end

  def subject
    self.changeset.comments
  end

  def description
    self.changeset.comments
  end

  # Returns a SQL conditions string used to find all issues visible by the specified user
  def self.visible_condition(user, options={})
    Project.allowed_to_condition(user, :view_reviews, options) do |role, user|
      if user.logged?
        case role.issues_visibility
          when 'all'
            nil
          when 'default'
            user_ids = [user.id] + user.groups.map(&:id).compact
            "(#{table_name}.is_private = #{connection.quoted_false} OR #{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
          when 'own'
            user_ids = [user.id] + user.groups.map(&:id).compact
            "(#{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
          else
            '1=0'
        end
      else
        "(#{table_name}.is_private = #{connection.quoted_false})"
      end
    end
  end

end

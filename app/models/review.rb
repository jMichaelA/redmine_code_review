class Review < ActiveRecord::Base

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

end

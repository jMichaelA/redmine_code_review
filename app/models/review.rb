class Review < ActiveRecord::Base

  belongs_to :user
  belongs_to :changeset
  belongs_to :project
  has_many :review_participants
  has_many :review_files

  validates_presence_of :changeset_id, :project_id, :priority_id

  alias_attribute :creator, :user

  def comment(text)
    #Nothing here yet
  end

end

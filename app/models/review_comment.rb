class ReviewComment < ActiveRecord::Base

  belongs_to :user
  belongs_to :review
  belongs_to :review_file

  alias_attribute :author, :user

  validates_presence_of :review_file
end
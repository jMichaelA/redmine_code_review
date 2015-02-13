class Review < ActiveRecord::Base

  belongs_to :changeset
  belongs_to :project
  #has_and_belongs_to_many :participants # if it is a table, should we create a model?  If we create a model, do we also create controllers etc?
  #has_many :comments
  def comment(text)
    #Nothing here yet
  end

end

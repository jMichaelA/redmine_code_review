class ReviewFile < ActiveRecord::Base

  belongs_to :review
  belongs_to :change
  has_many :review_comments


  def path
    change.path
  end

  # Replaces any existing order defined on the relation with the specified order.
  #
  #   User.order('email DESC').reorder('id ASC') # generated SQL has 'ORDER BY id ASC'
  #
  # Subsequent calls to order on the same relation will be appended. For example:
  #
  #   User.order('email DESC').reorder('id ASC').order('name ASC')
  #
  # generates a query with 'ORDER BY id ASC, name ASC'.
  #
  def reorder(*args)
    return self if args.blank?

    relation = clone
    relation.reordering_value = true
    relation.order_values = args.flatten
    relation
  end

  def self.get_by_review_and_file_id(review_id, file_id)
    file = ReviewFile.find(file_id)
    review = Review.find(review_id)

    if file.review_id != review.id
      return nil
    end

    file
  end
end
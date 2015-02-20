class CreateReviews < ActiveRecord::Migration
    def change
      create_table :reviews do |t|
        t.integer :changeset_id, :default => 0, :null => false
        t.integer :project_id, :default => 0, :null => false
        t.integer :user_id, :default => 0, :null => false
        t.date :due_date
        t.integer :priority_id, :default => 0, :null => false # Maps to a Enumeration of type IssuePriority
        t.timestamp :created_on
        t.timestamp :updated_on
        t.boolean :closed, :default => false
      end

      create_table :review_participants do |t|
        t.integer :review_id, :default => 0, :null => false
        t.integer :user_id, :default => 0, :null => false
      end

      create_table :review_files do |t|
        t.integer :review_id, :default => 0, :null => false
        t.integer :change_id, :default => 0, :null => false
        t.boolean :is_approved, :default => false, :null => false
      end

      create_table :review_comments do |t|
        t.integer :review_id, :default => 0, :null => false
        t.integer :user_id, :default => 0, :null => false
        t.integer :review_file_id, :default => 0, :null => false
        t.string :comment_text, :null => false
        t.timestamp :created_on
        t.boolean :is_read, :default => false
        t.boolean :is_blocker, :default => false
        t.boolean :is_accepted, :default => false
        t.string :location_path, :null => false
        t.string :location_side, :null => false
        t.integer :location_line_num, :default => 0, :null => false
      end
    end
end

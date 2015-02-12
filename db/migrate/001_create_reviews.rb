class CreateReviews < ActiveRecord::Migration

    def change
      create_table :reviews do |t|
        t.integer :changeset_id, :default => 0, :null => false
        t.integer :tracker_id, :default => 0, :null => false
        t.integer :project_id, :default => 0, :null => false
        t.date :due_date
        t.integer :priority_id, :default => 0, :null => false
        t.timestamp :created_on, :default => Time.now
        t.timestamp :updated_on
        t.boolean :closed, :default => false
      end

      #add_index "reviews", ["project_id"], :name => "reviews_project_id"

      create_table :review_participants do |t|
        t.column "review_id", :integer, :default => 0, :null => false
        t.column "participant_id", :integer, :default => 0, :null => false
        t.column "role_id", :integer, :default => 0, :null => false
      end

      create_table :review_roles do |t|
        t.column "role_name", :string, :null => false
        t.column "can_approve", :boolean, :null => false
        t.column "can_comment", :boolean, :null => false
      end
    end
end

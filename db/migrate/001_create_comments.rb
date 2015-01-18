class CreateComments < ActiveRecord::Migration
  def change
    if table_exists?(:comments)
      drop_table :comments      
    end
    
    create_table :comments do |t|
      t.string :text
      t.string :author
      t.integer :author_id
    end
  end  
end

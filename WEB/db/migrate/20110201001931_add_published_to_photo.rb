class AddPublishedToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :published, :boolean, :default => true
  end

  def self.down
    remove_column :photos, :published
  end
end

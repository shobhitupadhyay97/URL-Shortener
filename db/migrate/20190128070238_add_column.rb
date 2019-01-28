class AddColumn < ActiveRecord::Migration[5.2]
  def change
  	add_column :urls, :count, :integer
  end
end

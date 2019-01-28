class UrlTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :urls do |t|
      t.string :long_url
      t.string :url_digest
      t.string :domain
      t.string :short_url
      t.timestamps
  	end
end
end
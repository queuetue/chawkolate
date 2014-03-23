class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid
      t.string :api_client_id
      t.string :provider
      t.string :provider_email
      t.string :email
      t.string :handle
      t.string :name
      t.string :image_url
      t.integer :agent_id
      t.timestamps
    end
  end
end

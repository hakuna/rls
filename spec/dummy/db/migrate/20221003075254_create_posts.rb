# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end

    rls_tenant_table :posts
  end
end

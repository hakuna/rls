# frozen_string_literal: true

class CreateTenants < ActiveRecord::Migration[6.1]
  def change
    create_table :tenants do |t|
      t.string :identifier, null: false, unique: true

      t.timestamps
    end
  end
end

# frozen_string_literal: true

# Creates the widgets table inline in the test database for ArelQuery specs.
ActiveRecord::Schema.define do
  create_table :widgets, force: true do |t|
    t.string  :name,   null: false
    t.integer :weight
    t.timestamps
  end
end

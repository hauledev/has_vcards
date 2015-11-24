class AddTestFieldToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :Test_Field, :string
  end
end

class AddDisplayTextToSalePrices < ActiveRecord::Migration
  def change
    add_column :spree_sale_prices, :discount_deadline, :bool, default: false
    add_index :spree_sale_prices, :discount_deadline
  end
end

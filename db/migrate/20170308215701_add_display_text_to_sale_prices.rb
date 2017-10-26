class AddDisplayTextToSalePrices < ActiveRecord::Migration
  def change
    add_column :spree_sale_prices, :display_text, :string
  end
end

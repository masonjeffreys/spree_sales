unless !defined?(Deface)
	Deface::Override.new(virtual_path: "spree/admin/shared/_product_tabs",
	                     name: "add_sale_prices_tab",
	                     insert_bottom: "[data-hook='admin_product_tabs']",
	                     partial: 'spree/admin/sale_prices/product_tab',
	                     disabled: false,
	                     :original => '91d2e3fc8e3849c9bf5d65cd7ea871b25ad01b06')
end

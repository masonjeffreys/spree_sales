module Spree
  module Admin
    class SalePricesController < BaseController
      before_filter :load_product
      before_filter :load_sale_prices

      respond_to :js, :html

      # Show all sale prices for a product
      def index
        @sale_price = Spree::SalePrice.new
        @sale_price.calculator = Spree::Calculator.new
      end

      # Create a new sale price
      def create
        @sale_price = Spree::SalePrice.new sale_price_params

        if @sale_price.valid?
          @product.put_on_sale sale_price_params[:value], sale_price_params
          redirect_to admin_product_sale_prices_path(@product)
        else
          render :index
        end
      end

      # Edit a sale price
      def edit
        @sale_price = Spree::SalePrice.find(params[:id])
      end

      # Update a sale price
      def update
        @sale_price = Spree::SalePrice.find(params[:id])
        if @sale_price.update(sale_price_params)
          flash[:success] = "Saved the updates"
          redirect_to admin_product_sale_prices_path(@product)          
        else
          flash[:error] = "Error saving your updates"
          render 'edit'
        end 
      end

      # Destroy a sale price
      def destroy
        sale_price = Spree::SalePrice.find(params[:id])
        sale_price.destroy
        @product.touch

        respond_with(sale_price)
      end


      private
        # Load the product as a before filter. Redirect to the referer if no product is found
        def load_product
          @product = Spree::Product.find_by(slug: params[:product_id])
          redirect_to request.referer unless @product.present?
        end

        # Load product sale_prices as a before filter.
        def load_sale_prices
          @sale_prices = @product.sale_prices

          @variants = @product.variants_including_master.map do |variant|
            [variant.id, variant.sku_and_options_text]
          end
          @variants.insert(0, [:all_variants, Spree.t(:all_variants)])
          @prices = @product.prices.includes(:store).map do |price|
            if price.store
              ["#{price.store.code}: #{price.display_original_price.to_html}", price.id]
            else
              ["no store: #{price.display_original_price.to_html}", price.id]
            end
          end
        end

        # Sale price params
        def sale_price_params
          params.require(:sale_price).permit(
            :value,
            :start_at,
            :end_at,
            :currency,
            :variant,
            :display_text,
            calculator_attributes: [:type]
          )
        end
    end
  end
end

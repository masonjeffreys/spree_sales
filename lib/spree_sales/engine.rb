module SpreeSales
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_sales'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "spree.register.sale_configuration", :before => :load_config_initializers do |app|
      puts "--- registering sales config"
      Spree::SalesConfiguration::Config = Spree::SalesConfiguration.new
      Spree::SalesConfiguration::Config.calculators << Spree::Calculator::AmountSalePriceCalculator
      Spree::SalesConfiguration::Config.calculators << Spree::Calculator::PercentOffSalePriceCalculator
    end

    def self.activate
      puts "---- activating SpreeSales Engine"
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end

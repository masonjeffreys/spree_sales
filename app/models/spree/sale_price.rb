module Spree
  class SalePrice < ActiveRecord::Base

    attr_accessor :currency, :variant, :display_text

    # TODO validations
    belongs_to :default_price, :class_name => "Spree::Price", :foreign_key => "price_id"
    belongs_to :price, :class_name => "Spree::Price"
    has_one :calculator, :class_name => "Spree::Calculator", :as => :calculable, :dependent => :destroy

    accepts_nested_attributes_for :calculator

    validates :calculator, :presence => true
    validates :value, :numericality => { :greater_than => 0 }

    validates_presence_of :start_at
    validates :end_at, date: { after: :start_at, allow_blank: true }

    delegate :currency, to: :default_price

    scope :active, -> { where(enabled: true).where('(start_at <= ? OR start_at IS NULL) AND (end_at >= ? OR end_at IS NULL)', Time.now, Time.now) }

    # TODO make this work or remove it
    #def self.calculators
    #  Rails.application.config.spree.calculators.send(self.to_s.tableize.gsub('/', '_').sub('spree_', ''))
    #end
    def initialize attrs={}
      attrs[:calculator] = attrs[:calculator].constantize.new() if attrs[:calculator].present?

      # ToDo - Pendiente queda asignar el id del precio que se esta cambiando

      super attrs
    end

    # TODO - Merge this method and active scope so that definition is only in 1 place
    def is_active?
      n = Time.now.utc
      if self.enabled and ( start_at <= n or start_at == nil ) and ( end_at >= n or end_at == nil )
        true
      else
        false
      end
    end

    def calculator_type
      calculator.class.to_s if calculator
    end

    def short_calculator_type
      self.calculator_type.demodulize
    end

    def new_amount
      calculator.compute self
    end

    def enable
      update_attribute(:enabled, true)
    end

    def disable
      update_attribute(:enabled, false)
    end

    def start(end_time = nil)
      end_time = nil if end_time.present? && end_time <= Time.now # if end_time is not in the future then make it nil (no end)
      attr = { end_at: end_time, enabled: true }
      attr[:start_at] = Time.now if self.start_at.present? && self.start_at > Time.now # only set start_at if it's not set in the past
      update_attributes(attr)
    end

    def stop
      update_attributes({ end_at: Time.now, enabled: false })
    end

    def descriptive_name
      if self.is_active?
        "Active #{self.short_calculator_type} [#{self.nice_date_range}]"
      else
        "Inactive #{self.short_calculator_type} [#{self.nice_date_range}]"
      end
    end

    def nice_date_range
      if self.start_at == nil and self.end_at == nil
        "no date range"
      else
        "#{self.nice_start_at} : #{self.nice_end_at}"
      end
    end

    def nice_start_at
      self.start_at == nil ? "-" : self.start_at.strftime("%m/%d/%Y at %I:%M%p")
    end

    def nice_end_at
      self.end_at == nil ? "-" : self.end_at.strftime("%m/%d/%Y at %I:%M%p")
    end

    # Convenience method for displaying the price of a given sale_price in the table
    def display_price
      Spree::Money.new(new_amount, {currency: currency})
    end
  end
end

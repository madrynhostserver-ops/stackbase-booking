class Order < ApplicationRecord
  PaymentVerificationError = Class.new(StandardError)

  belongs_to :user
  belongs_to :biker, class_name: "User", optional: true, inverse_of: :assigned_orders
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  STATUSES = %w[received preparing ready out_for_delivery completed cancelled].freeze
  PAYMENT_STATUSES = %w[pending paid failed refunded].freeze
  FULFILLMENT_TYPES = %w[pickup delivery].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :fulfillment_type, inclusion: { in: FULFILLMENT_TYPES }
  validates :delivery_address, presence: true, if: -> { fulfillment_type == "delivery" }
  validates :delivery_zone, inclusion: { in: PizzeriaRules::ZONES.keys }, if: -> { fulfillment_type == "delivery" }
  validates :phone, presence: true
  validates :total_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :delivery_fee_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :delivery_latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :delivery_longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  def paid?
    payment_status == "paid"
  end

  def mark_paid!(payment_intent_id:, stripe_event_id:, amount_cents:, currency:)
    with_lock do
      return if paid? && stripe_event_id == self.stripe_event_id

      unless payment_status == "pending"
        raise PaymentVerificationError, "Invalid payment transition"
      end
      unless amount_cents == total_cents && currency.to_s.downcase == self.currency
        raise PaymentVerificationError, "Stripe amount or currency does not match order"
      end

      update!(
        payment_status: "paid",
        paid_at: Time.current,
        stripe_payment_intent_id: payment_intent_id,
        stripe_event_id: stripe_event_id,
      )
    end
  end
end

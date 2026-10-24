class User < ApplicationRecord
  has_secure_password
  has_many :orders, dependent: :restrict_with_exception
  has_many :assigned_orders, class_name: "Order", foreign_key: :biker_id, inverse_of: :biker, dependent: :nullify

  normalizes :email, with: ->(email) { email.strip.downcase }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[customer admin biker] }
  validates :password, length: { minimum: 8 }, if: :password
end

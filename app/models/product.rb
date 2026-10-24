class Product < ApplicationRecord
  StoreOnlyError = Class.new(StandardError)
  SALES_CHANNELS = %w[online store_only].freeze
  CATEGORIES = %w[pizza special custom].freeze

  has_many :order_items, dependent: :restrict_with_exception
  has_one_attached :image

  scope :published, -> { where(published: true, available: true) }

  validates :name, :description, presence: true
  validates :download_url, presence: true, unless: :pizza?
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, inclusion: { in: %w[eur usd ars] }
  validates :category, inclusion: { in: CATEGORIES }
  validates :sales_channel, inclusion: { in: SALES_CHANNELS }
  validate :image_format_and_size

  def pizza?
    CATEGORIES.include?(category)
  end

  def online_orderable?
    sales_channel == "online"
  end

  private

  def image_format_and_size
    return unless image.attached?

    errors.add(:image, "must be a JPEG, PNG, or WebP") unless image.content_type.in?(%w[image/jpeg image/png image/webp])
    errors.add(:image, "must be smaller than 8 MB") if image.byte_size > 8.megabytes
  end
end

class PizzeriaSetting < ApplicationRecord
  validates :address, presence: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  def self.instance
    first_or_create!(address: "Plaza Ban Josip Jelačić", latitude: 45.8131, longitude: 15.9775)
  end
end

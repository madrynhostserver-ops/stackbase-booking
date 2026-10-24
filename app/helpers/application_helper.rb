module ApplicationHelper
  PIZZA_IMAGES = {
    "Margherita" => "https://images.unsplash.com/photo-1574071318508-1cdbab80d002",
    "Pepperoni" => "https://images.unsplash.com/photo-1579751626657-72bc17010498",
    "Cuatro quesos" => "https://images.unsplash.com/photo-1513104890138-7c749659a591",
    "Vegetariana" => "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38",
    "Prosciutto e rucola" => "https://images.unsplash.com/photo-1574071318508-1cdbab80d002",
  }.freeze
  CURRENCY_UNITS = { "eur" => "€", "usd" => "US$", "ars" => "ARS $" }.freeze

  def pizza_image_url(product, width: 900)
    if product.image.attached?
      return url_for(product.image)
    end

    "#{PIZZA_IMAGES.fetch(product.name, PIZZA_IMAGES.fetch("Margherita"))}?auto=format&fit=crop&w=#{width}&q=82"
  end

  def pizza_description(product)
    I18n.t("menu.descriptions.#{product.name.parameterize}", default: product.description)
  end

  def currency_unit(currency)
    CURRENCY_UNITS.fetch(currency.to_s.downcase, currency.to_s.upcase)
  end

  def order_status_label(status)
    I18n.t("status.#{status}", default: status.humanize)
  end

  def payment_status_label(status)
    I18n.t("status.#{status}", default: status.humanize)
  end
end

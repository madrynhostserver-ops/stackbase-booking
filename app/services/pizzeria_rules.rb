class PizzeriaRules
  InvalidDelivery = Class.new(StandardError)
  ClosedError = Class.new(StandardError)

  ZONES = {
    "zone_1" => { label: "Zona 1 · Centro", fee_cents: 0, minimum_order_cents: 1000 },
    "zone_2" => { label: "Zona 2 · Cercanías", fee_cents: 250, minimum_order_cents: 1500 },
    "zone_3" => { label: "Zona 3 · Ampliada", fee_cents: 400, minimum_order_cents: 2000 },
  }.freeze
  OPEN_MINUTES = 11 * 60
  CLOSE_MINUTES = 24 * 60 + 60

  class << self
    def open?(at: Time.current)
      minutes = at.hour * 60 + at.min
      minutes >= OPEN_MINUTES || minutes < (CLOSE_MINUTES - (24 * 60))
    end

    def zone_options
      ZONES.map { |key, zone| [zone[:label], key] }
    end

    def delivery_quote(zone:, subtotal_cents:)
      details = ZONES.fetch(zone) { raise InvalidDelivery, "Zona de reparto no válida" }
      if subtotal_cents < details[:minimum_order_cents]
        raise InvalidDelivery, "El pedido mínimo para #{details[:label]} es #{details[:minimum_order_cents]} céntimos"
      end

      details[:fee_cents]
    end
  end
end

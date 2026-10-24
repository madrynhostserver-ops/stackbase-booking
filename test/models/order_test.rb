require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "mark_paid is idempotent at the model boundary" do
    user = User.create!(email: "test@example.com", password: "Password123!")
    order = user.orders.create!(total_cents: 4900, currency: "eur", phone: "+34 600 000 000")

    order.mark_paid!(
      payment_intent_id: "pi_test",
      stripe_event_id: "evt_test",
      amount_cents: 4900,
      currency: "eur",
    )
    order.mark_paid!(
      payment_intent_id: "pi_test",
      stripe_event_id: "evt_test",
      amount_cents: 4900,
      currency: "eur",
    )

    assert order.paid?
    assert_equal "pi_test", order.stripe_payment_intent_id
    assert_equal "received", order.status
  end

  test "mark_paid rejects a second payment transition" do
    user = User.create!(email: "transition@example.com", password: "Password123!")
    order = user.orders.create!(total_cents: 4900, currency: "eur", phone: "+34 600 000 000")
    order.update!(payment_status: "failed")

    assert_raises(Order::PaymentVerificationError) do
      order.mark_paid!(
        payment_intent_id: "pi_test",
        stripe_event_id: "evt_test",
        amount_cents: 4900,
        currency: "eur",
      )
    end
  end

  test "delivery quote applies the zone fee and minimum order" do
    assert_equal 250, PizzeriaRules.delivery_quote(zone: "zone_2", subtotal_cents: 1500)
    assert_raises(PizzeriaRules::InvalidDelivery) do
      PizzeriaRules.delivery_quote(zone: "zone_2", subtotal_cents: 1499)
    end
  end

  test "business hours include the service window" do
    assert PizzeriaRules.open?(at: Time.zone.parse("2026-10-10 12:00"))
    assert PizzeriaRules.open?(at: Time.zone.parse("2026-10-11 00:30"))
    refute PizzeriaRules.open?(at: Time.zone.parse("2026-10-10 10:59"))
    refute PizzeriaRules.open?(at: Time.zone.parse("2026-10-11 01:00"))
  end
end

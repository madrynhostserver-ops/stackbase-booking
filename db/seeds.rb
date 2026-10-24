require "faker"

User.find_or_create_by!(email: "admin@stackbase.local") do |user|
  user.password = "ChangeMe123!"
  user.role = "admin"
end

User.find_or_create_by!(email: "cliente@stackbase.local") do |user|
  user.password = "ChangeMe123!"
end

User.find_or_create_by!(email: "biker@stackbase.local") do |user|
  user.password = "ChangeMe123!"
  user.role = "biker"
end
biker = User.find_by!(email: "biker@stackbase.local")
biker.update!(display_name: "Marko Biker", phone: "+385 91 555 0101")

3.times do |index|
  email = "faker.biker.#{index + 1}@stackbase.local"
  user = User.find_or_initialize_by(email: email)
  user.password = "Password123!"
  user.role = "biker"
  user.display_name = Faker::Name.name
  user.phone = Faker::PhoneNumber.phone_number
  user.save!
end

pizzas = [
  ["Margherita", 1190, "Tomate, mozzarella fresca, albahaca y aceite de oliva."],
  ["Pepperoni", 1390, "Tomate, mozzarella y pepperoni crujiente."],
  ["Cuatro quesos", 1490, "Mozzarella, gorgonzola, parmesano y provolone."],
  ["Vegetariana", 1350, "Pimientos, champiñones, cebolla morada, aceitunas y mozzarella."],
  ["Prosciutto e rucola", 1590, "Jamón serrano, rúcula, mozzarella y parmesano."],
]

pizzas.each do |name, price_cents, description|
  product = Product.find_or_initialize_by(name: name)
  product.assign_attributes(
    description: description,
    price_cents: price_cents,
    currency: "eur",
    category: "pizza",
    available: true,
    published: true,
    download_url: "",
  )
  product.save!
end

Product.where.not(name: pizzas.map(&:first)).update_all(published: false)

10.times do |index|
  email = "faker.customer.#{index + 1}@stackbase.local"
  user = User.find_or_initialize_by(email: email)
  user.password = "Password123!"
  user.role = "customer"
  user.save!
end

pizzeria_setting = PizzeriaSetting.instance
pizzeria_setting.update!(address: "Plaza Ban Josip Jelačić", latitude: 45.8131, longitude: 15.9775)
customer = User.find_by!(email: "cliente@stackbase.local")
margherita = Product.find_by!(name: "Margherita")
demo_order = Order.find_or_initialize_by(user: customer, delivery_address: "Ulica Baltazara Bogišića 1, Zagreb")
demo_order.assign_attributes(
  status: "out_for_delivery",
  fulfillment_type: "delivery",
  delivery_zone: "zone_1",
  delivery_latitude: 45.8106853,
  delivery_longitude: 15.9968448,
  phone: "+385 91 555 0101",
  delivery_fee_cents: 0,
  total_cents: margherita.price_cents,
  currency: margherita.currency,
  biker: biker,
)
demo_order.save!
demo_order.order_items.delete_all
demo_order.order_items.create!(product: margherita, unit_price_cents: margherita.price_cents, quantity: 1)

puts "Pizzeria seeded: #{Product.published.count} pizzas and #{User.count} users"

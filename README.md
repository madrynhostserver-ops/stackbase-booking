# StackBase Pizzería Web

MVP web para una pizzería local con Rails 8.1, SQLite en desarrollo y Stripe Checkout.

## Funcionalidades

- Menú público de pizzas con datos demo generados con Faker.
- Autenticación con contraseña cifrada.
- Pedidos con cantidad, teléfono, notas y opción de retiro o envío.
- Horario operativo de 11:00 a 01:00 y zonas de reparto con pedido mínimo y tarifa.
- Panel admin para pizzas y estados de pedidos.
- Checkout alojado por Stripe.
- Webhook firmado, idempotente y con verificación de sesión, importe y moneda.
- Interfaz responsive para menú, pedido, login y administración.

## Instalación local

```powershell
bundle install
$env:STRIPE_SECRET_KEY="sk_test_..."
$env:STRIPE_WEBHOOK_SECRET="whsec_..."
bundle exec rails db:prepare
bundle exec rails db:seed
bundle exec rails server
```

Visita `http://127.0.0.1:3100`.

Usuario demo: `cliente@stackbase.local` / `ChangeMe123!`.

En Windows también puedes ejecutar `start_stackbase_store.bat` desde esta carpeta o desde la terminal integrada de VS Code. El script prepara la base de datos, comprueba si Rails ya está activo y arranca la aplicación en `http://127.0.0.1:3100` sin reiniciarla ni ejecutar seeds en cada arranque. Para cargar datos demo de forma explícita, ejecuta `bundle exec rails db:seed`.

## Stripe local

```powershell
stripe listen --forward-to 127.0.0.1:3100/stripe/webhook
```

Usa exclusivamente la tarjeta de prueba `4242 4242 4242 4242`, una fecha futura y cualquier CVC.

Antes de producción:

1. Configurar claves como secretos del proveedor de despliegue.
2. Verificar zona de reparto, horarios, moneda, impuestos y política de cancelación.
3. Configurar el webhook `checkout.session.completed` en Stripe.
4. Sustituir los datos Faker por el menú real del local.
5. Ejecutar Brakeman, bundler-audit y la suite de pruebas.

El importe se calcula desde la base de datos y el webhook valida firma, pedido, sesión, importe, moneda y estado de pago antes de marcarlo como pagado. El panel administrativo solo puede modificar el estado operativo (`received`, `preparing`, `ready`, `out_for_delivery`, `completed` o `cancelled`); nunca puede confirmar un pago.

# Changelog — StackBase Pizzería

Cambios relevantes de la aplicación Rails de pizzería. Las entradas describen
funcionalidad presente en el código y no sustituyen una validación de
producción.

## [Unreleased]

### Añadido

- Menú público de pizzas con listado y detalle de producto.
- Datos demo para clientes, administradores, repartidores, pizzas y un pedido
  de ejemplo.
- Registro e inicio de sesión con contraseñas cifradas.
- Creación de pedidos con cantidades, teléfono, notas y modalidad de retiro o
  envío.
- Reglas operativas para horario de atención, zonas de reparto, pedido mínimo
  y tarifa de envío.
- Panel administrativo para gestionar pizzas, disponibilidad y estados de
  pedidos.
- Perfil de repartidor con asignación de pedidos y actualización de ubicación.
- Configuración de la dirección y coordenadas de la pizzería.
- Checkout alojado de Stripe y webhook firmado para confirmar pagos.
- Protección del webhook con validación de firma, sesión, pedido, importe,
  moneda, estado e idempotencia del evento.
- Rutas de salud en `/up` y arranque local en `127.0.0.1:3100`.
- Lanzador de Windows [`start_stackbase_store.bat`](./start_stackbase_store.bat)
  para preparar la base de datos, evitar arranques duplicados y registrar el
  servidor.

### Datos y dominio

- Productos con precio en céntimos, moneda, categoría, publicación y
  disponibilidad.
- Pedidos con estados separados de pago y operación.
- Estados operativos soportados: `received`, `preparing`, `ready`,
  `out_for_delivery`, `completed` y `cancelled`.
- Seguimiento de repartidor mediante coordenadas y fecha de actualización.
- Moneda demo configurada en EUR.

### Interfaz

- Interfaz responsive para menú, detalle, autenticación, pedidos y paneles
  internos.
- Traducciones disponibles en español, inglés y croata.

## StackBase Corporate — web principal

### Añadido

- Página corporativa Dark Premium con inicio, soluciones, app, precios y
  contacto.
- Rutas localizadas para español, inglés y croata.
- Navegación con selector de idioma y enlaces que conservan el locale activo.
- Formulario de contacto con persistencia, validaciones, consentimiento,
  honeypot antispam, rate limiting, mailer y job.
- Registro de usuarios con contraseña y opción de Google OAuth.
- Portal de cliente en `/cliente` con proyectos, progreso, métricas,
  cotizaciones y pagos del usuario autenticado.
- Panel administrativo para operación, permisos, proyectos, actividades,
  métricas, cotizaciones y configuración de pagos.
- Cotizaciones explícitas en ARS, con moneda de origen, tipo de cambio,
  importe calculado, vencimiento y estado de aprobación.
- Integración base de GalioPay con credenciales cifradas, sandbox por defecto,
  webhook HMAC, timestamp, idempotencia y reconciliación de importe y moneda.

### Estado operativo

- La web principal se ejecuta localmente en `http://127.0.0.1:3000`.
- La configuración de pagos permanece deshabilitada hasta configurar secretos y
  habilitarla explícitamente desde administración.
- La aplicación corporativa mantiene su base PostgreSQL y backend separados de
  la aplicación de pizzería.

### Pendiente

- Ejecutar y registrar la revisión visual completa, accesibilidad y responsive.
- Completar la validación de CI/CD, seguridad y pruebas de integración.
- Configurar credenciales externas solo mediante secretos del entorno.
- No activar pagos de producción ni publicar sin autorización humana.

## Verificado localmente

- La aplicación responde en `http://127.0.0.1:3100`.
- La ruta `/up` responde correctamente.
- El menú público carga cinco pizzas demo.
- La aplicación se inicia con Rails 8.1.4, SQLite en desarrollo y Ruby
  3.3.12 en el entorno local actual.

## Pendiente antes de producción

- Sustituir el menú y los datos Faker por datos reales del local.
- Configurar las claves y el webhook de Stripe como secretos del entorno.
- Definir y revisar zonas, horarios, moneda, impuestos y política de
  cancelación del negocio.
- Ejecutar y registrar Brakeman, bundler-audit y la suite completa de pruebas.
- Completar una prueba end-to-end de checkout y webhook en modo test.
- Revisar accesibilidad, responsive y flujo operativo con usuarios reales.
- Configurar despliegue, observabilidad, copias de seguridad y procedimiento
  de rollback.
- No activar cobros reales ni publicar sin autorización humana explícita.

(() => {
  const initializeOrderForm = (form) => {
    if (form.dataset.initialized === "true") return;
    form.dataset.initialized = "true";
    const fulfillment = form.querySelector('[name="fulfillment_type"]');
    const zone = form.querySelector('[name="delivery_zone"]');
    const address = form.querySelector('[name="delivery_address"]');
    const location = form.querySelector("[data-delivery-location]");
    const quantity = form.querySelector('[name="quantity"]');
    const total = form.querySelector("[data-order-total]");
    const price = Number.parseInt(form.closest("section").querySelector("[data-order-price]").dataset.orderPrice, 10);
    const currency = form.closest("section").querySelector("[data-order-price]").dataset.orderCurrency;
    const deliveryFields = [zone, address].filter(Boolean);

    const update = () => {
      const delivery = fulfillment.value === "delivery";
      deliveryFields.forEach((field) => {
        const label = form.querySelector(`label[for="${field.id}"]`);
        [field, label].filter(Boolean).forEach((element) => {
          element.classList.toggle("is-hidden", !delivery);
          if (element === field) element.disabled = !delivery;
        });
        location?.classList.toggle("is-hidden", !delivery);
      });
      zone.required = delivery;
      address.required = delivery;
      const amount = price * Math.max(1, Math.min(20, Number.parseInt(quantity.value, 10) || 1));
      total.textContent = new Intl.NumberFormat("es-ES", { style: "currency", currency }).format(amount / 100);
    };

    fulfillment.addEventListener("change", update);
    quantity.addEventListener("input", update);
    form.addEventListener("submit", () => {
      const submit = form.querySelector("[data-submit-feedback]");
      if (!submit || !form.checkValidity()) return;

      submit.disabled = true;
      const loadingLabels = {
        en: "Preparing your order…",
        es: "Preparando tu pedido…",
        hr: "Pripremamo vašu narudžbu…",
      };
      submit.textContent = loadingLabels[document.documentElement.lang] || loadingLabels.en;
    });
    update();
  };

  const initialize = () => {
    document.querySelectorAll("[data-order-form]").forEach(initializeOrderForm);
    document.querySelectorAll("[data-delivery-location]").forEach(initializeDeliveryLocation);
    document.querySelectorAll("[data-order-tracking]").forEach(initializeOrderTracking);
    document.querySelectorAll("[data-biker-location]").forEach(initializeBikerLocation);
    document.querySelectorAll("[data-pizzeria-location]").forEach(initializePizzeriaLocation);
  };

  const initializePizzeriaLocation = (container) => {
    const button = container.querySelector("[data-use-pizzeria-location]");
    const status = container.querySelector("[data-pizzeria-location-status]");
    const latitude = container.querySelector('[name="pizzeria_setting[latitude]"]');
    const longitude = container.querySelector('[name="pizzeria_setting[longitude]"]');
    const mapElement = container.querySelector("[data-pizzeria-location-map]");
    let map;
    let marker;
    if (!button || !latitude || !longitude || !navigator.geolocation) {
      button?.classList.add("is-hidden");
    }

    const renderMap = (point) => {
      if (typeof L === "undefined" || !mapElement) return;
      if (!map) {
        map = L.map(mapElement).setView(point, 16);
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
          attribution: "&copy; OpenStreetMap contributors",
          maxZoom: 19,
        }).addTo(map);
      }
      marker?.remove();
      marker = L.marker(point).addTo(map);
      map.setView(point, 16);
    };
    const savedPoint = [Number.parseFloat(latitude.value), Number.parseFloat(longitude.value)];
    if (savedPoint.every((value) => !Number.isNaN(value))) renderMap(savedPoint);
    if (!button || !navigator.geolocation) return;

    button.addEventListener("click", () => {
      status.textContent = "Obteniendo ubicación…";
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const point = [position.coords.latitude, position.coords.longitude];
          latitude.value = point[0].toFixed(7);
          longitude.value = point[1].toFixed(7);
          renderMap(point);
          status.textContent = "Ubicación seleccionada. Guarda para confirmar el punto.";
        },
        () => {
          status.textContent = "No se pudo obtener la ubicación. Introduce las coordenadas manualmente.";
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 60000 },
      );
    });
  };

  const initializeBikerRoute = (container, origin) => {
    if (typeof L === "undefined") return;
    const mapElement = container.querySelector("[data-biker-route-map]");
    const status = container.querySelector("[data-biker-route-status]");
    const destination = [
      Number.parseFloat(container.dataset.destinationLatitude),
      Number.parseFloat(container.dataset.destinationLongitude),
    ];
    if (!mapElement || destination.some(Number.isNaN)) return;
    const configuredOrigin = [
      Number.parseFloat(container.dataset.originLatitude),
      Number.parseFloat(container.dataset.originLongitude),
    ];
    origin ||= configuredOrigin.some(Number.isNaN) ? null : configuredOrigin;

    container._bikerRouteMap ||= L.map(mapElement).setView(destination, 14);
    if (!container.dataset.mapReady) {
      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution: "&copy; OpenStreetMap contributors",
        maxZoom: 19,
      }).addTo(container._bikerRouteMap);
      L.marker(destination).addTo(container._bikerRouteMap).bindPopup("Delivery destination");
      container.dataset.mapReady = "true";
    }
    if (!origin) return;

    const coordinates = `${origin[1]},${origin[0]};${destination[1]},${destination[0]}`;
    fetch(`https://router.project-osrm.org/route/v1/driving/${coordinates}?overview=full&geometries=geojson`)
      .then((response) => response.ok ? response.json() : Promise.reject(new Error("Route unavailable")))
      .then((data) => {
        const route = data.routes?.[0];
        if (!route) throw new Error("Route unavailable");
        container._bikerRouteLine?.remove();
        container._bikerRouteLine = L.geoJSON(route.geometry, { color: "#b94d32", weight: 5 }).addTo(container._bikerRouteMap);
        container._bikerRouteMap.fitBounds(container._bikerRouteLine.getBounds(), { padding: [20, 20] });
        status.textContent = `${(route.distance / 1000).toFixed(1)} km · ${Math.max(1, Math.ceil(route.duration / 60))} min`;
      })
      .catch(() => {
        status.textContent = "Route unavailable. Use the delivery address.";
      });
  };

  const initializeOrderTracking = (container) => {
    if (container.dataset.initialized === "true") return;
    container.dataset.initialized = "true";
    const status = container.querySelector("[data-tracking-status]");
    const updated = container.querySelector("[data-tracking-updated]");
    const eta = container.querySelector("[data-tracking-eta]");
    const mapElement = container.querySelector("[data-tracking-map]");
    let map;
    let marker;
    const refresh = async () => {
      const response = await fetch(container.dataset.orderTracking, { headers: { Accept: "application/json" } });
      if (!response.ok) return;
      const data = await response.json();
      status.textContent = data.latitude ? "Your biker is on the way." : "Waiting for the biker location.";
      if (data.updated_at) updated.textContent = `Last update: ${new Date(data.updated_at).toLocaleTimeString()}`;
      if (!data.latitude || typeof L === "undefined") return;
      const point = [data.latitude, data.longitude];
      if (data.delivery_latitude && data.delivery_longitude) {
        const toRadians = (value) => value * Math.PI / 180;
        const deltaLat = toRadians(data.delivery_latitude - data.latitude);
        const deltaLon = toRadians(data.delivery_longitude - data.longitude);
        const a = Math.sin(deltaLat / 2) ** 2 + Math.cos(toRadians(data.latitude)) * Math.cos(toRadians(data.delivery_latitude)) * Math.sin(deltaLon / 2) ** 2;
        const distanceKm = 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        const minutes = Math.max(1, Math.ceil((distanceKm / 25) * 60));
        eta.textContent = eta.dataset.trackingEta.replace("%{minutes}", minutes);
      }
      if (!map) {
        map = L.map(mapElement).setView(point, 15);
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", { attribution: "&copy; OpenStreetMap contributors", maxZoom: 19 }).addTo(map);
      } else {
        map.setView(point);
      }
      marker?.remove();
      marker = L.marker(point).addTo(map);
    };
    refresh();
    container._trackingTimer = window.setInterval(refresh, 10000);
  };

  const initializeBikerLocation = (container) => {
    if (container.dataset.initialized === "true") return;
    container.dataset.initialized = "true";
    const button = container.querySelector("[data-start-location]");
    const status = container.querySelector("[data-biker-status]");
    document.querySelectorAll("[data-biker-route]").forEach((route) => initializeBikerRoute(route));
    if (!button || !navigator.geolocation) return;
    button.addEventListener("click", () => {
      const update = () => navigator.geolocation.getCurrentPosition(async (position) => {
        const currentPoint = [position.coords.latitude, position.coords.longitude];
        const orders = Array.from(document.querySelectorAll("[data-biker-order]"));
        for (const order of orders) {
          await fetch(order.dataset.bikerOrder, {
            method: "PATCH",
            headers: { "Content-Type": "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content },
            body: JSON.stringify({ latitude: position.coords.latitude, longitude: position.coords.longitude }),
          });
        }
        document.querySelectorAll("[data-biker-route]").forEach((route) => initializeBikerRoute(route, currentPoint));
        status.textContent = "Location updated. Next update in 10 seconds.";
      }, () => { status.textContent = "Location permission was not granted."; });
      update();
      window.setInterval(update, 10000);
      button.disabled = true;
      status.textContent = "Sharing your location with assigned customers.";
    });
  };

  const initializeDeliveryLocation = (container) => {
    if (container.dataset.initialized === "true") return;
    container.dataset.initialized = "true";
    const button = container.querySelector("[data-use-location]");
    const status = container.querySelector("[data-location-status]");
    const latitude = container.querySelector("[data-location-latitude]");
    const longitude = container.querySelector("[data-location-longitude]");
    const mapElement = container.querySelector("#delivery-map");
    if (!button || !navigator.geolocation || typeof L === "undefined") {
      button?.classList.add("is-hidden");
      return;
    }

    let map;
    let marker;
    button.addEventListener("click", () => {
      status.textContent = "Locating your device…";
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const point = [position.coords.latitude, position.coords.longitude];
          latitude.value = point[0];
          longitude.value = point[1];
          if (!map) {
            map = L.map(mapElement).setView(point, 16);
            L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
              attribution: "&copy; OpenStreetMap contributors",
              maxZoom: 19,
            }).addTo(map);
          }
          marker?.remove();
          marker = L.marker(point).addTo(map);
          status.textContent = "Location selected. Enter the address above to complete delivery details.";
        },
        () => {
          status.textContent = "Location access was not available. Enter the address manually.";
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 60000 },
      );
    });
  };

  document.addEventListener("DOMContentLoaded", initialize);
  document.addEventListener("turbo:load", initialize);
})();

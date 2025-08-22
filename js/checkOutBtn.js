document.addEventListener("DOMContentLoaded", () => {
  const checkoutBtn = document.getElementById("checkoutBtn");
  if (!checkoutBtn) return;

  checkoutBtn.addEventListener("click", () => {
    // get chosen validator from the radios on product.html
    const selected = document.querySelector('input[name="selectedValidator"]:checked');
    if (!selected) {
      alert("Please select a validator before proceeding!");
      return;
    }

    // `car` comes from car-details.js (already included before this script)
    if (typeof car === "undefined" || !car) {
      alert("Car details not loaded yet. Please try again.");
      return;
    }

    const params = new URLSearchParams({
      carName: car.name,
      carPrice: car.price,
      carImage: (car.images && car.images[0]) || "",
      validator: selected.value, // e.g. "validator3"
    });

    window.location.href = `order-summary.html?${params.toString()}`;
  });
});

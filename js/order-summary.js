const validatorsData = {
  validator1: { name: "Validator 1", image: "images/validators/validator1.jpg" },
  validator2: { name: "Validator 2", image: "images/validators/validator2.jpg" },
  validator3: { name: "Validator 3", image: "images/validators/validator3.png" },
  validator4: { name: "Validator 4", image: "images/validators/validator4.png" },
  validator5: { name: "Validator 5", image: "images/validators/validator5.png" },
  validator6: { name: "Validator 6", image: "images/validators/validator6.png" },
  validator7: { name: "Validator 7", image: "images/validators/validator7.png" },
};

const urlParams = new URLSearchParams(window.location.search);
const carName = urlParams.get("carName");
const carPrice = urlParams.get("carPrice");
const carImage = urlParams.get("carImage");
const validatorKey = urlParams.get("validator");
const validator = validatorsData[validatorKey];

// Fill the existing placeholders in order-summary.html
if (carName) document.getElementById("carName").textContent = carName;
if (carPrice) document.getElementById("carPrice").textContent = carPrice;
if (carImage) document.getElementById("carImage").src = carImage;
if (validator) {
  document.getElementById("validatorName").textContent = validator.name;
  document.getElementById("validatorImage").src = validator.image;
}

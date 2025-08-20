const carsData = {
    gle53: {
      name: "Mercedes GLE53",
      description: "Experience a perfect blend of luxury and performance.",
      features: [
        "Sporty exterior design with AMG styling",
        "3.0L turbo inline-6 engine",
        "Advanced safety features including lane assist",
        "Luxury interior with premium materials",
        "High-resolution infotainment system"
      ],
      price:"$97,855",
      images: [
        "images/products/gle1.jpg",
        "images/products/gle2.jpg",
        "images/products/gle3.jpg",
        "images/products/gle4.jpg"
      ]
    },
    bmwM4: {
      name: "BMW M4",
      description: "Track-ready power with street-ready comfort.",
      features: [
        "Aggressive coupe styling",
        "3.0L twin-turbo inline-6 engine",
        "High-performance brakes and suspension",
        "Driver-focused cockpit",
        "Apple CarPlay and Android Auto"
      ],
       price:"$48,000",
      images: [
        "images/products/bmw1.jpeg",
        "images/products/bmw2.jpeg",
        "images/products/bmw3.jpeg",
        "images/products/bmw4.jpeg"
      ]
    },
    rangeRover: {
      name: "Range Rover",
      description: "Command the road with elegance and dominance.",
      features: [
        "Bold and modern exterior design",
        "Refined cabin with premium leather",
        "All-terrain 4x4 capabilities",
        "Panoramic sunroof and ambient lighting",
        "InControl infotainment system"
      ],
       price:"$49,980",
      images: [
        "images/products/range1.jpg",
        "images/products/range2.jpg",
        "images/products/range3.jpg",
        "images/products/range4.jpg"
      ]
    },
    landCruiser: {
      name: "Toyota Land Cruiser",
      description: "A symbol of durability and off-road power.",
      features: [
        "Rugged 4x4 capability",
        "8-passenger seating",
        "V8 power and superior towing",
        "Toyota Safety Sense",
        "Navigation and entertainment suite"
      ],
       price:"$ 69,390",
      images: [
        "images/products/cruiser1.jpg",
        "images/products/cruiser2.jpg",
        "images/products/cruiser3.jpg",
        "images/products/cruiser4.jpg"
      ]
    }
  };

  // Read URL param
  const urlParams = new URLSearchParams(window.location.search);
  const carKey = urlParams.get("car");

  // Load car if key matches
  const car = carsData[carKey];
  if (car) {
    // Update name & description
    document.getElementById("carName").textContent = car.name;
    document.getElementById("carDescription").textContent = car.description;
    document.getElementById("carPrice").textContent = car.price;

    // Update features
    const featuresList = document.getElementById("carFeatures");
    featuresList.innerHTML = car.features.map(feature => `<li>${feature}</li>`).join("");

    // Update images
    const preview = document.getElementById("preview");
    const thumbs = document.querySelectorAll(".thumb");

    preview.src = car.images[0];

    thumbs.forEach((thumb, index) => {
      thumb.src = car.images[index];
      thumb.classList.remove("border-blue-500", "opacity-100");
      if (index === 0) {
        thumb.classList.add("border-blue-500", "opacity-100");
      }

      thumb.addEventListener("click", () => {
        preview.src = car.images[index];
        thumbs.forEach(t => t.classList.remove("border-blue-500", "opacity-100"));
        thumb.classList.add("border-blue-500", "opacity-100");
      });
    });
  }
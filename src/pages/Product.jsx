"use client"

import { useState, useEffect } from "react"
import { useSearchParams } from "react-router-dom"
import "../css/Navbar.css"
import "../css/Footer.css"
import "../css/Home.css"

const Product = () => {
  const [searchParams] = useSearchParams()
  const [selectedValidator, setSelectedValidator] = useState("")
  const [currentCar, setCurrentCar] = useState(null)
  const [previewImage, setPreviewImage] = useState("")

  const carsData = {
    gle53: {
      name: "Mercedes GLE53",
      description: "Experience a perfect blend of luxury and performance.",
      features: [
        "Sporty exterior design with AMG styling",
        "3.0L turbo inline-6 engine",
        "Advanced safety features including lane assist",
        "Luxury interior with premium materials",
        "High-resolution infotainment system",
      ],
      price: "$75,000",
      images: [
        "/images/products/gle1.jpg",
        "/images/products/gle2.jpg",
        "/images/products/gle3.jpg",
        "/images/products/gle4.jpg",
      ],
    },
    bmwM4: {
      name: "BMW M4",
      description: "Track-ready power with street-ready comfort.",
      features: [
        "Aggressive coupe styling",
        "3.0L twin-turbo inline-6 engine",
        "High-performance brakes and suspension",
        "Driver-focused cockpit",
        "Apple CarPlay and Android Auto",
      ],
      price: "$28,000",
      images: [
        "/images/products/bmw1.jpeg",
        "/images/products/bmw2.jpeg",
        "/images/products/bmw3.jpeg",
        "/images/products/bmw4.jpeg",
      ],
    },
    rangeRover: {
      name: "Range Rover",
      description: "Command the road with elegance and dominance.",
      features: [
        "Bold and modern exterior design",
        "Refined cabin with premium leather",
        "All-terrain 4x4 capabilities",
        "Panoramic sunroof and ambient lighting",
        "InControl infotainment system",
      ],
      price: "$32,000",
      images: [
        "/images/products/range1.jpg",
        "/images/products/range2.jpg",
        "/images/products/range3.jpg",
        "/images/products/range4.jpg",
      ],
    },
  }

  const validators = [
    {
      id: "validator1",
      name: "Validator 1",
      status: "Online",
      stars: 2,
      validations: 867,
      successRate: "94.6%",
      image: "/images/validators/validator1.jpg",
    },
    {
      id: "validator2",
      name: "Validator 2",
      status: "Online",
      stars: 3,
      validations: 1600,
      successRate: "96.7%",
      image: "/images/validators/validator2.jpg",
    },
    {
      id: "validator3",
      name: "Validator 3",
      status: "Online",
      stars: 3,
      validations: 1107,
      successRate: "96.9%",
      image: "/images/validators/validator3.png",
    },
    {
      id: "validator4",
      name: "Validator 4",
      status: "Online",
      stars: 2,
      validations: 2715,
      successRate: "96.5%",
      image: "/images/validators/validator4.png",
    },
    {
      id: "validator5",
      name: "Validator 5",
      status: "Offline",
      stars: 4,
      validations: 1092,
      successRate: "93.3%",
      image: "/images/validators/validator5.png",
    },
    {
      id: "validator6",
      name: "Validator 6",
      status: "Offline",
      stars: 2,
      validations: 308,
      successRate: "91.1%",
      image: "/images/validators/validator6.png",
    },
    {
      id: "validator7",
      name: "Validator 7",
      status: "Offline",
      stars: 2,
      validations: 1839,
      successRate: "98.1%",
      image: "/images/validators/validator7.png",
    },
  ]

  useEffect(() => {
    const carKey = searchParams.get("car")
    const car = carsData[carKey]
    if (car) {
      setCurrentCar({ ...car, key: carKey })
      setPreviewImage(car.images[0])
    }
  }, [searchParams])

  const handleCheckout = () => {
    if (!selectedValidator) {
      alert("Please select a validator before checkout")
      return
    }

    const selectedValidatorData = validators.find((v) => v.id === selectedValidator)
    const orderData = {
      car: currentCar,
      validator: selectedValidatorData,
    }

    const orderParams = new URLSearchParams({
      carKey: currentCar.key,
      validatorId: selectedValidator,
    })
    window.location.href = `/order?${orderParams.toString()}`
  }

  if (!currentCar) {
    return <div className="text-white text-center p-8">Car not found</div>
  }

  return (
    <div className="bg-gray-800 font-sans">
      {/* Product Details Section */}
      <div className="flex w-4/5 flex-col md:flex-row mx-auto">
        <div className="w-full md:w-2/3 p-4 m-4">
          <h2 className="text-2xl text-[#00E5FF] mb-2">Product Details</h2>
          <h3 className="text-white text-xl mb-1">{currentCar.name}</h3>
          <p className="text-white text-base">{currentCar.description}</p>

          <p className="text-white font-bold mt-2">Features:</p>
          <ul className="text-white text-base">
            {currentCar.features.map((feature, index) => (
              <li key={index}>{feature}</li>
            ))}
          </ul>

          <p className="text-white font-bold mt-2">Price:</p>
          <p className="text-white font-black text-3xl">{currentCar.price}</p>
        </div>

        {/* Photo Gallery */}
        <div className="w-full md:w-1/3 m-4 p-4">
          <div className="w-full mx-auto">
            <div className="w-full mb-4">
              <img
                src={previewImage || "/placeholder.svg"}
                alt="Preview"
                className="w-full rounded-xl object-contain"
              />
            </div>

            <div className="flex gap-3">
              {currentCar.images.map((image, index) => (
                <img
                  key={index}
                  src={image || "/placeholder.svg"}
                  alt={`Thumb ${index + 1}`}
                  className={`w-1/4 rounded-xl cursor-pointer transition ${
                    previewImage === image ? "opacity-100 border-2 border-blue-500" : "opacity-60 hover:opacity-100"
                  }`}
                  onClick={() => setPreviewImage(image)}
                />
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Validator Selection */}
      <div className="container mx-auto p-4 sm:p-6 lg:p-8">
        <h2 className="text-2xl text-[#00E5FF] mb-2">Choose A Validator</h2>
        <div className="rounded-xl p-6 sm:p-8 md:p-10 max-w-6xl mx-auto">
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-7 gap-4 justify-items-center">
            {validators.map((validator) => (
              <label key={validator.id} className="flex flex-col items-center p-2">
                <div className="relative w-24 h-24 sm:w-28 sm:h-28 rounded-full overflow-hidden shadow-md flex-shrink-0 mb-2">
                  <img
                    src={validator.image || "/placeholder.svg"}
                    alt={validator.name}
                    className="w-full h-full object-cover"
                  />
                </div>
                <span
                  className={`font-semibold text-sm mb-1 ${
                    validator.status === "Online" ? "text-blue-600" : "text-gray-500"
                  }`}
                >
                  {validator.status}
                </span>
                <div className="star-rating mb-1">
                  <span className="full-star">{"⭐".repeat(validator.stars)}</span>
                </div>
                <p className="text-gray-100 text-xs text-center">Validations: {validator.validations}</p>
                <p className="text-gray-100 text-xs text-center">Success Rate: {validator.successRate}</p>
                <input
                  type="radio"
                  name="selectedValidator"
                  value={validator.id}
                  className="w-5 h-5 accent-[#00E5FF]"
                  onChange={(e) => setSelectedValidator(e.target.value)}
                />
              </label>
            ))}
          </div>
        </div>
      </div>

      {/* Checkout Button */}
      <div className="text-center mt-8">
        <button
          onClick={handleCheckout}
          className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-full font-bold mt-6 mb-6"
        >
          Checkout
        </button>
      </div>
    </div>
  )
}

export default Product

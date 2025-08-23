"use client"

import { useState, useEffect } from "react"
import { useSearchParams } from "react-router-dom"
import "../css/Navbar.css"
import "../css/Footer.css"
import "../css/Home.css"

const Order = () => {
  const [searchParams] = useSearchParams()
  const [orderData, setOrderData] = useState(null)

  const carsData = {
    gle53: {
      name: "Mercedes GLE53",
      description: "Experience a perfect blend of luxury and performance.",
      price: "$75,000",
      image: "/images/products/gle1.jpg",
    },
    bmwM4: {
      name: "BMW M4",
      description: "Track-ready power with street-ready comfort.",
      price: "$28,000",
      image: "/images/products/bmw1.jpeg",
    },
    rangeRover: {
      name: "Range Rover",
      description: "Command the road with elegance and dominance.",
      price: "$32,000",
      image: "/images/products/range1.jpg",
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
    const carKey = searchParams.get("carKey")
    const validatorId = searchParams.get("validatorId")

    const car = carsData[carKey]
    const validator = validators.find((v) => v.id === validatorId)

    if (car && validator) {
      setOrderData({ car, validator })
    }
  }, [searchParams])

  const handleMakePayment = () => {
    alert("Payment functionality would be implemented here")
  }

  if (!orderData) {
    return <div className="text-white text-center p-8">Order data not found</div>
  }

  return (
    <div className="font-sans min-h-screen bg-gray-900 p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl text-[#00E5FF] mb-8 text-center">Order Summary</h1>

        <div className="bg-gray-800 rounded-xl p-6 mb-6">
          <h2 className="text-2xl text-white mb-4">Selected Car</h2>
          <div className="flex flex-col md:flex-row gap-6">
            <div className="md:w-1/3">
              <img
                src={orderData.car.image || "/placeholder.svg"}
                alt={orderData.car.name}
                className="w-full rounded-lg object-cover"
              />
            </div>
            <div className="md:w-2/3">
              <h3 className="text-xl text-white mb-2">{orderData.car.name}</h3>
              <p className="text-gray-300 mb-4">{orderData.car.description}</p>
              <p className="text-2xl text-[#00E5FF] font-bold">{orderData.car.price}</p>
            </div>
          </div>
        </div>

        <div className="bg-gray-800 rounded-xl p-6 mb-6">
          <h2 className="text-2xl text-white mb-4">Selected Validator</h2>
          <div className="flex items-center gap-4">
            <div className="w-20 h-20 rounded-full overflow-hidden">
              <img
                src={orderData.validator.image || "/placeholder.svg"}
                alt={orderData.validator.name}
                className="w-full h-full object-cover"
              />
            </div>
            <div>
              <h3 className="text-lg text-white">{orderData.validator.name}</h3>
              <p className={`text-sm ${orderData.validator.status === "Online" ? "text-blue-400" : "text-gray-400"}`}>
                {orderData.validator.status}
              </p>
              <div className="flex items-center gap-2">
                <span>{"⭐".repeat(orderData.validator.stars)}</span>
                <span className="text-gray-300 text-sm">
                  {orderData.validator.validations} validations • {orderData.validator.successRate} success rate
                </span>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-gray-800 rounded-xl p-6 mb-8">
          <h2 className="text-2xl text-white mb-4">Total Amount</h2>
          <p className="text-3xl text-[#00E5FF] font-bold">{orderData.car.price}</p>
        </div>

        <div className="text-center">
          <button
            onClick={handleMakePayment}
            className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 rounded-full font-bold text-lg transition-colors"
          >
            Make Payment
          </button>
        </div>
      </div>
    </div>
  )
}

export default Order


import "../css/Navbar.css"
import "../css/Footer.css"
import "../css/Home.css"

const Home = () => {
  const handleProductRedirect = (carType) => {
    window.location.href = `/product?car=${carType}`
  }

  return (
    <div className="w-full bg-gray-800">
      {/* Hero Section */}
      <section className="hero-section  text-white py-20 px-4">
        <div className="container mx-auto text-center">
          <h1 className="text-4xl md:text-6xl font-bold mb-4">Find Your Perfect Car</h1>
          <p className="text-xl mb-8">Discover amazing deals on quality vehicles</p>

          {/* Search Form */}
          <div className="bg-white rounded-lg p-6 max-w-4xl mx-auto">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <select className="p-3 border rounded-lg text-gray-700">
                <option>Select Make</option>
                <option>Toyota</option>
                <option>Honda</option>
                <option>Mercedes</option>
              </select>
              <select className="p-3 border rounded-lg text-gray-700">
                <option>Select Model</option>
                <option>Camry</option>
                <option>Accord</option>
                <option>GLE</option>
              </select>
              <select className="p-3 border rounded-lg text-gray-700">
                <option>Price Range</option>
                <option>$0 - $20,000</option>
                <option>$20,000 - $50,000</option>
                <option>$50,000+</option>
              </select>
              <button className="bg-gray-800 text-white p-3 rounded-lg hover:bg-green-600 transition-colors">
                Search Cars
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Cars Section */}
      <section className="py-16 px-4 bg-gray-50">
        <div className="container mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12 text-gray-800">Featured Cars</h2>

          {/* Cars Grid - Side by Side */}
          <div className="flex flex-col md:flex-row gap-8 max-w-6xl mx-auto">
            {/* Car 1 */}
            <div className="flex-1 bg-white rounded-lg shadow-lg overflow-hidden">
              <img src="/images/car1.png" alt="Mercedes GLE 53" className="w-full h-48 object-cover" />
              <div className="p-6">
                <h3 className="text-xl font-bold mb-2">Mercedes GLE 53</h3>
                <p className="text-gray-600 mb-4">Nigeria used: 10,000 Milage</p>
                <div className="flex justify-between items-center mb-4">
                  <span className="text-2xl font-bold text-green-600">$75,000</span>
                  <span className="text-sm text-gray-500">2021</span>
                </div>
                <button
                  onClick={() => handleProductRedirect("gle53")}
                  className="w-full bg-gray-800 text-white py-2 px-4 rounded-lg hover:bg-green-600 transition-colors"
                >
                  Shop Now
                </button>
              </div>
            </div>

            {/* Car 2 */}
            <div className="flex-1 bg-white rounded-lg shadow-lg overflow-hidden">
              <img src="images/car2.jpg" alt="Toyota Camry" className="w-full h-48 object-cover" />
              <div className="p-6 ">
                <h3 className="text-xl font-bold mb-2">BMW M4 </h3>
                <p className="text-gray-600 mb-4">London Used : 25,490 Milage</p>
                <div className="flex justify-between items-center mb-4">
                  <span className="text-2xl font-bold text-green-600">$28,000</span>
                  <span className="text-sm text-gray-500">2024</span>
                </div>
                <button
                  onClick={() => handleProductRedirect("bmwM4")}
                  className="w-full bg-gray-800 text-white py-2 px-4 rounded-lg hover:bg-green-600 transition-colors"
                >
                  Shop Now
                </button>
              </div>
            </div>

            {/* Car 3 */}
            <div className="flex-1 bg-white rounded-lg shadow-lg overflow-hidden">
              <img src="images/car3.png" alt="Honda Accord" className="w-full h-48 object-cover" />
              <div className="p-6">
                <h3 className="text-xl font-bold mb-2">Range Rover </h3>
                <p className="text-gray-600 mb-4">London Used : 25,490 Milage</p>
                <div className="flex justify-between items-center mb-4">
                  <span className="text-2xl font-bold text-green-600">$32,000</span>
                  <span className="text-sm text-gray-500">2024</span>
                </div>
                <button
                  onClick={() => handleProductRedirect("rangeRover")}
                  className="w-full bg-gray-800 text-white py-2 px-4 rounded-lg hover:bg-green-600 transition-colors"
                >
                  Shop Now
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section className="py-16 px-4">
        <div className="container mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12 text-white">How It Works</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-4xl mx-auto">
            <div className="text-center">
              <div className="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-green-600">1</span>
              </div>
              <div className="text-white">
              <h3 className="text-xl font-bold mb-2">Browse Cars</h3>
              <p className="">Search through our extensive inventory of quality vehicles</p>
              </div>
            </div>
            <div className="text-center">
              <div className="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-green-600">2</span>
              </div>
              <div className="text-white">
              <h3 className="text-xl font-bold mb-2">Schedule Test Drive</h3>
              <p className="">Book a test drive to experience your chosen vehicle</p>
              </div>
            </div>
            <div className="text-center">
              <div className="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-green-600">3</span>
              </div>
              <div className="text-white">
              <h3 className="text-xl font-bold mb-2">Complete Purchase</h3>
              <p className="">Finalize your purchase with our easy financing options</p>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}

export default Home

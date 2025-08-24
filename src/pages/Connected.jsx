
const Connection =()=>{

  return (
    <div className="bg-gray-800 font-sans min-h-screen">

      <div className="flex  flex-col justify-center items-center  max-w-[1200px] "> 
        
        <div className=" mt-5">
          <i class="fa-solid fa-wallet text-white text-6xl"></i>
        </div>

        <div className="text-white  ">
          <h2 className="text-2xl font-bold">Wallet Connected !</h2>
          <p classname="text-xl ">Set Shipment address to call smart contract</p>
        </div>

        <div className="">
          <form className="w-full max-w-lg bg-gray-900 p-6 rounded-2xl shadow-lg my-5 ">
  <h2 className="text-2xl font-bold text-white mb-4">Shipment Address</h2>
  
  <div className="mb-4">
    <label className="block text-gray-300 text-sm mb-2" htmlFor="fullName">
      Full Name
    </label>
    <input
      type="text"
      id="fullName"
      placeholder="John Doe"
      className="w-full px-4 py-2 rounded-lg bg-gray-800 text-white border border-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
    />
  </div>

  <div className="mb-4">
    <label className="block text-gray-300 text-sm mb-2" htmlFor="street">
      Street Address
    </label>
    <input
      type="text"
      id="street"
      placeholder="123 Main St"
      className="w-full px-4 py-2 rounded-lg bg-gray-800 text-white border border-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
    />
  </div>

  <div className="mb-4">
    <label className="block text-gray-300 text-sm mb-2" htmlFor="city">
      City
    </label>
    <input
      type="text"
      id="city"
      placeholder="Lagos"
      className="w-full px-4 py-2 rounded-lg bg-gray-800 text-white border border-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
    />
  </div>

  <div className="grid grid-cols-2 gap-4 mb-4">
    <div>
      <label className="block text-gray-300 text-sm mb-2" htmlFor="state">
        State
      </label>
      <input
        type="text"
        id="state"
        placeholder="Kaduna"
        className="w-full px-4 py-2 rounded-lg bg-gray-800 text-white border border-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
    </div>

    <div>
      <label className="block text-gray-300 text-sm mb-2" htmlFor="zip">
        ZIP / Postal Code
      </label>
      <input
        type="text"
        id="zip"
        placeholder="110001"
        className="w-full px-4 py-2 rounded-lg bg-gray-800 text-white border border-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
    </div>
  </div>

  <div className="mb-6">
    <label className="block text-gray-300 text-sm mb-2" htmlFor="country">
      Country
    </label>
    <input
      type="text"
      id="country"
      placeholder="Nigeria"
      className="w-full px-4 py-2 rounded-lg bg-gray-800 text-white border border-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
    />
  </div>

  <button
    type="submit"
    className="w-full bg-blue-600 text-white py-2 px-4 rounded-lg font-semibold hover:bg-blue-700 transition"
  >
    Save Address
  </button>
</form>

        </div>

      </div>
      

      
    </div>
  )
}

export default Connection

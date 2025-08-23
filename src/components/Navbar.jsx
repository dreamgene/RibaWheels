"use client"

import { useState } from "react"
import { Link } from "react-router-dom"
// import "../css/Navbar.css" // import the CSS file

function Navbar() {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <nav className="bg-gray-900 text-white shadow-md">
      <div className="container mx-auto flex justify-between items-center px-6 py-4">
        {/* Logo */}
        <Link to="/" className="text-2xl font-bold tracking-wide text-cyan-400">
          RibaWheels
        </Link>

        {/* Desktop Menu */}
        <div
          className={`flex-col md:flex-row md:flex gap-6 absolute md:static top-16 left-0 w-full md:w-auto bg-gray-900 md:bg-transparent p-6 md:p-0 transition-all duration-300 ease-in-out ${
            isOpen ? "flex" : "hidden"
          }`}
        >
          <Link to="/" className="text-lg hover:text-cyan-400 transition" onClick={() => setIsOpen(false)}>
            Home
          </Link>
          <button className="bg-cyan-500 hover:bg-cyan-600 text-white font-semibold px-4 py-2 rounded-lg transition">
            Connect Wallet
          </button>
        </div>

        {/* Hamburger Button (Mobile) */}
        <button className="md:hidden text-2xl focus:outline-none" onClick={() => setIsOpen(!isOpen)}>
          {isOpen ? "✖" : "☰"}
        </button>
      </div>
    </nav>
  )
}

export default Navbar

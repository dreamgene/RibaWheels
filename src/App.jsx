import { BrowserRouter as Router, Routes, Route } from "react-router-dom"
import Navbar from "./components/Navbar.jsx"
import Home from "./pages/Home.jsx"
import Product from "./pages/Product.jsx"
import Order from "./pages/Order.jsx"
import "./index.css"
import Footer from "./components/Footer.jsx"

function App() {
  return (
    
    <Router>
      <Navbar />
      <div className="App">
        
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/product" element={<Product />} />
          <Route path="/order" element={<Order />} />
        </Routes>
        
      </div>
      <Footer />
    </Router>
  )
}

export default App;

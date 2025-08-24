
const Payment =()=>{

  return (
    <div className="bg-gray-800 font-sans min-h-screen">

      <div className="flex  flex-col justify-center items-center  max-w-[1200px] "> 
        
        <div className=" mt-5">
          <i class="fa-solid fa-circle-check text-6xl text-blue-600"></i>
        </div>

        <div className="text-white  ">
          <h2 className="text-2xl font-bold">Payment succesful !</h2>
          <p classname="text-xl ">Money Sent to escrow awaiting validation</p>
        </div>

        <div className="flex gap-4 mt-5 ">
         <button className="bg-blue-600 text-black p-2 rounded-lg w-[150px] ">Home</button>
         <button className="bg-blue-600 text-black p-2 rounded-lg w-[150px] ">Validation Status</button>


        </div>

      </div>
      

      
    </div>
  )
}

export default Payment

import { Route, Routes, createBrowserRouter, createRoutesFromElements } from "react-router-dom";
import { SwapPage } from "./SwapPage";
import LiquidityPool from "./CreateLPComponent/LiquidityPool";

export const RouterMain:React.FC=()=>{
    return <Routes>
    <Route path='/liqudityPool' element={<LiquidityPool />}/>
    <Route path='/' element={<SwapPage />}/>
   </Routes>
}
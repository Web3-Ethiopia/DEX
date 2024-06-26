import { Route, Routes, createBrowserRouter, createRoutesFromElements } from "react-router-dom";
import { SwapPage } from "./SwapPage";

export const RouterMain:React.FC=()=>{
    return <Routes>
    <Route path='/' element={<SwapPage />}/>
   </Routes>
}
import React from "react";


function returnTypes (_assetClass) {

if (_assetClass === "3" || _assetClass === "4" || _assetClass === "5" || _assetClass === "6"){
    return (
    <>
    <option value="0">Choose a firearm type</option>
    <option value="Shotgun">Shotgun</option>
    <option value="Rifle/Carbine">Rifle/Carbine</option>
    <option value="Handgun">Handgun</option>
    <option value="Destructive Device">Destructive Device</option>
    <option value="NFA Classification">NFA Classification</option>    
    </>
    )}

else { 
return('0')
}
}

export default returnTypes
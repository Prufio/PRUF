import React from "react";


function returnTypes (_assetClass, _isNFA) {
if(_isNFA === false){
if (_assetClass === "3"){
    return (
    <>
    <option value="0">CHOOSE A FIREARM TYPE</option>
    <option value="Shotgun (Pump Action)">Shotgun (Pump Action)</option>
    <option value="Shotgun (Semi Auto)">Shotgun (Semi Auto)</option>
    <option value="Shotgun (Lever Action)">Shotgun (Lever Action)</option>
    <option value="Shotgun (Bolt Action)">Shotgun (Bolt Action)</option>
    <option value="Shotgun (Other)">Shotgun (Other)</option>

    <option value="Rifle (Bolt Action)">Rifle (Bolt Action)</option>
    <option value="Rifle (Semi Auto)">Rifle (Semi Auto)</option>
    <option value="Rifle (Lever Action)">Rifle (Lever Action)</option>
    <option value="Rifle (Other)">Rifle (Other)</option>

    <option value="Handgun (Semi Auto)">Handgun (Semi Auto)</option>
    <option value="Handgun (Revolver)">Handgun (Revolver)</option>
    <option value="Handgun (Other)">Handgun (Other)</option>
    </>
    )}
}

else if (_isNFA === true){
    if (_assetClass === "3"){
        return (
        <>
        <option value="0">CHOOSE A FIREARM TYPE</option>
        <option value="Short Barrel Shotgun">Short Barrel Shotgun</option>
        <option value="Short Barrel Rifle">Short Barrel Rifle</option>
        <option value="Machine Gun">Machine Gun</option>
        <option value="Supressor">Supressor</option>
        <option value="Destructive Device">Destructive Device</option>
        <option value="AOW">AOW</option>    
        </>
        )}
    }

else { 
return('0')
}
}

export default returnTypes
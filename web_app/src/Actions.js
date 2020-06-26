import React from "react";


function returnActions (_assetClass) {

if (_assetClass === "3" || _assetClass === "4" || _assetClass === "5"){
    return (
    <>
    <option value="0">Choose an action style</option>
    <option value="Semi automatic">Semi automatic</option>
    <option value="Fully automatic">Fully-automatic</option>
    <option value="Bolt action">Bolt action</option>
    <option value="Pump action">Pump action</option>
    <option value="Lever action">Lever action</option>
    <option value="Revolver (double action)">Revolver (double action)</option>
    <option value="Revolver (single action)">Revolver (single action)</option>    
    </>
    )}

else if (_assetClass === "6"){
    return(
    <>
    <option value="0">Choose an action style</option>
    <option value="Semi automatic">Semi automatic</option>
    <option value="Fully automatic">Fully-automatic</option>
    <option value="Bolt action">Bolt action</option>
    <option value="Pump action">Pump action</option>
    <option value="Lever action">Lever action</option>
    <option value="Revolver (double action)">Revolver (double action)</option>
    <option value="Revolver (single action)">Revolver (single action)</option>
    <option value="Machine Gun">Machine Gun</option>
    <option value="Supressor">Supressor</option>
    <option value="Short Barrel Rifle">Short barrel rifle</option>
    <option value="Revolver (single action)">Long barrel pistol</option>
    <option value="Revolver (single action)">Short barrel shotgun</option>
    <option value="Destructive Device">Destructive Device</option>
    </>
    )}
else { 
return('0')
}
}

export default returnActions
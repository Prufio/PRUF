

import React from "react";

function returnManufacturers(_assetClass) {

    if (_assetClass === "3") {
        return (
            <>
                <option value="0">CHOOSE A MANUFACTURER</option>
                <option value="556 Tactical">556 Tactical</option>
                <option value="Accurate Armory">Accurate Armory</option>
                <option value="Arctiier">Arctiier</option>
                <option value="Armi Dallera Custom">Armi Dallera Custom</option>
                <option value="Adcor Defense">Adcor Defense</option>
                <option value="Arsenal">Arsenal</option>
                <option value="Bb">Bb</option>
                <option value="Baikal">Baikal</option>
                <option value="Bravo Company Manufacturing">Bravo Company Manufacturing</option>
                <option value="Benelli">Benelli</option>
                <option value="Beretta">Beretta</option>
                <option value="Bersa">Bersa</option>
                <option value="Blaser">Blaser</option>
                <option value="Browning">Browning</option>
                <option value="B And T">B And T</option>
                <option value="Bushmaster">Bushmaster</option>
                <option value="Chiappa">Chiappa</option>
                <option value="Connecticut Valley Arms">Connecticut Valley Arms</option>
                <option value="CZ">CZ</option>
                <option value="Colt">Colt</option>
                <option value="Daniel Defense">Daniel Defense</option>
                <option value="FN">FN</option>
                <option value="Glock">Glock</option>
                <option value="Heckler And Koch">Heckler And Koch</option>
                <option value="Henry">Henry</option>
                <option value="Horizon Firearms">Horizon Firearms</option>
                <option value="Ithaca">Ithaca</option>
                <option value="IZh">IZh</option>
                <option value="Kel-Tec">Kel-Tec</option>
                <option value="Kimber">Kimber</option>
                <option value="McWhorter Rifles">McWhorter Rifles</option>
                <option value="Mossberg">Mossberg</option>
                <option value="MP">MP</option>
                <option value="MTs">MTs</option>
                <option value="OTs">OTs</option>
                <option value="Patriot Ordnance Factory">Patriot Ordnance Factory</option>
                <option value="Proarms">Proarms</option>
                <option value="Remington">Remington</option>
                <option value="Ruger">Ruger</option>
                <option value="Seekins Precision">Seekins Precision</option>
                <option value="S And T Motiv">S And T Motiv</option>
                <option value="Smith And Wesson">Smith And Wesson</option>
                <option value="Savage">Savage</option>
                <option value="SCCY">SCCY</option>
                <option value="Seraphim Armoury">Seraphim Armoury</option>
                <option value="SIG Sauer">SIG Sauer</option>
                <option value="Springfield Armory">Springfield Armory</option>
                <option value="SR">SR</option>
                <option value="Steyr">Steyr</option>
                <option value="STI International">STI International</option>
                <option value="Taurus">Taurus</option>
                <option value="TOZ">TOZ</option>
                <option value="UWS">UWS</option>
                <option value="Walther Arms">Walther Arms</option>
                <option value="Weatherby">Weatherby</option>
                <option value="Winchester">Winchester</option>
                <option value="Zastava Arms">Zastava Arms</option>
                <option value="OTHER">OTHER</option>
            </>
        )
    }

    else {
        return ('0')
    }
}

export default returnManufacturers
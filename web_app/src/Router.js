import React, { Component } from "react";
import { Route } from "react-router-dom";

import ClaimPipAsset from "./Pip/ClaimPipAsset";
import MintPipAsset from "./Pip/MintPipAsset";

import SetCosts from "./ACAdmin/SetCosts"
import EnableContract from "./ACAdmin/EnableContract"
import AddUser from "./ACAdmin/AddUser"
import UpdateACName from "./ACAdmin/UpdateACName"
import GetACData from "./ACAdmin/GetACData"
import IncreaseACShare from "./ACAdmin/IncreaseACShare"

import RetrieveRecord from "./AllCustodyTypes/RetrieveRecord";
import VerifyLite from "./AllCustodyTypes/VerifyLite"
import VerifyRightsholder from "./AllCustodyTypes/VerifyRightsholder";

import AddNote from "./Custodial/AddNote";
import DecrementCounter from "./Custodial/DecrementCounter";
import ForceModifyRecord from "./Custodial/ForceModifyRecord";
import ModifyDescription from "./Custodial/ModifyDescription";
import ModifyRecordStatus from "./Custodial/ModifyRecordStatus";
import NewRecord from "./Custodial/NewRecord";
import TransferAsset from "./Custodial/TransferAsset";
import EscrowManager from "./Custodial/EscrowManager";
import ExportAsset from "./Custodial/ExportAsset";
import ImportAsset from "./Custodial/ImportAsset";

import HomeMobile from "./Mobile/HomeMobile";
import RetrieveRecordMobile from "./Mobile/RetrieveRecordMobile";
import VerifyLiteMobile from "./Mobile/VerifyLiteMobile";

import AddNoteNC from "./NonCustodial/AddNoteNC";
import DecrementCounterNC from "./NonCustodial/DecrementCounterNC";
import EscrowManagerNC from "./NonCustodial/EscrowManagerNC";
import ImportAssetNC from "./NonCustodial/ImportAssetNC";
import ExportAssetNC from "./NonCustodial/ExportAssetNC";
import ForceModifyRecordNC from "./NonCustodial/ForceModifyRecordNC";
import ModifyDescriptionNC from "./NonCustodial/ModifyDescriptionNC";
import ModifyRecordStatusNC from "./NonCustodial/ModifyRecordStatusNC";
import NewRecordNC from "./NonCustodial/NewRecordNC";
import TransferAssetNC from "./NonCustodial/TransferAssetNC";
import AssetDashboard from "./NonCustodial/AssetDashboard"

function Router(routeRequest) {
    if (routeRequest === "authUser") {
        return (
            <>  
                <Route path="/new-record" component={NewRecord} />
                <Route path="/retrieve-record" component={RetrieveRecord} />
                <Route path="/force-transfer-asset" component={ForceModifyRecord} />
                <Route path="/import-asset" component={ImportAsset} />
                <Route path="/transfer-asset" component={TransferAsset} />
                <Route path="/modify-record-status" component={ModifyRecordStatus} />
                <Route path="/decrement-counter" component={DecrementCounter} />
                <Route path="/modify-description" component={ModifyDescription} />
                <Route path="/add-note" component={AddNote} />
                <Route path="/export-asset" component={ExportAsset} />
                <Route path="/verify-rights-holder" component={VerifyRightsholder} />
                <Route path="/manage-escrow" component={EscrowManager} />
                <Route path="/mint-pip-asset" component={MintPipAsset} />
                <Route path="/claim-pip-asset" component={ClaimPipAsset} />
            </>
        )
    }

    else if (routeRequest === "NCAdmin") {
        return (
            <>
                <Route path="/new-record-NC" component={NewRecordNC} />
                <Route path="/retrieve-record" component={RetrieveRecord} />
                <Route path="/force-modify-record-NC" component={ForceModifyRecordNC} />
                <Route path="/transfer-asset-NC" component={TransferAssetNC} />
                <Route path="/modify-record-status-NC" component={ModifyRecordStatusNC} />
                <Route path="/decrement-counter-NC" component={DecrementCounterNC} />
                <Route path="/modify-description-NC" component={ModifyDescriptionNC} />
                <Route path="/add-note-NC" component={AddNoteNC} />
                <Route path="/import-asset-NC" component={ImportAssetNC} />
                <Route path="/export-asset-NC" component={ExportAssetNC} />
                <Route path="/verify-rights-holder" component={VerifyRightsholder} />
                <Route path="/manage-escrow-NC" component={EscrowManagerNC} />
                <Route path="/mint-pip-asset" component={MintPipAsset} />
                <Route path="/claim-pip-asset" component={ClaimPipAsset} />
                <Route path="/asset-dashboard" component={AssetDashboard} />
            </>)
    }

    else if (routeRequest === "NCUser") {
        return (
            <>
                <Route path="/retrieve-record" component={RetrieveRecord} />
                <Route path="/force-modify-record-NC" component={ForceModifyRecordNC} />
                <Route path="/transfer-asset-NC" component={TransferAssetNC} />
                <Route path="/modify-record-status-NC" component={ModifyRecordStatusNC} />
                <Route path="/decrement-counter-NC" component={DecrementCounterNC} />
                <Route path="/modify-description-NC" component={ModifyDescriptionNC} />
                <Route path="/add-note-NC" component={AddNoteNC} />
                <Route path="/import-asset-NC" component={ImportAssetNC} />
                <Route path="/export-asset-NC" component={ExportAssetNC} />
                <Route path="/verify-rights-holder" component={VerifyRightsholder} />
                <Route path="/manage-escrow-NC" component={EscrowManagerNC} />
                <Route path="/mint-pip-asset" component={MintPipAsset} />
                <Route path="/claim-pip-asset" component={ClaimPipAsset} />
                <Route path="/asset-dashboard" component={AssetDashboard} />
            </>)
    }

    else if (routeRequest === "ACAdmin") {
        return (
            <>
                <Route path="/add-user" component={AddUser} />
                <Route path="/enable-contract" component={EnableContract} />
                <Route path="/set-costs" component={SetCosts} />
                <Route path="/update-ac-name" component={UpdateACName} />
                <Route path="/mint-pip-asset" component={MintPipAsset} />
                <Route path="/claim-pip-asset" component={ClaimPipAsset} />
                <Route path="/get-ac-data" component={GetACData} />
                <Route path="/increase-ac-share" component={IncreaseACShare} />
            </>)
    }

    else if (routeRequest === "basic") {
        return (
            <>
                <Route path="/verify-lite" component={VerifyLite} />
                <Route path="/verify-rights-holder" component={VerifyRightsholder} />
                <Route path="/retrieve-record" component={RetrieveRecord} />
                <Route path="/mint-pip-asset" component={MintPipAsset} />
                <Route path="/claim-pip-asset" component={ClaimPipAsset} />
                <Route path="/asset-dashboard" component={AssetDashboard} />
            </>
        )
    }

    else if (routeRequest === "noAddr") {
        return (
            <>
                <Route path="/verify-lite" component={VerifyLite} />
                <Route path="/retrieve-record" component={RetrieveRecord} />
                <Route path="/" component={HomeMobile} />
                <Route path="/verify-lite-mobile" component={VerifyLiteMobile} />
                <Route path="/retrieve-record-mobile" component={RetrieveRecordMobile} />
            </>
        )
    }

    else {
        return (
            <>
            </>
        )
    }

}

export default Router;
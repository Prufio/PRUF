import React, { Component } from "react";
import { Route } from "react-router-dom";

import SetCosts from "./ACAdmin/SetCosts"
import EnableContract from "./ACAdmin/EnableContract"
import AddUser from "./ACAdmin/AddUser"
import UpdateACName from "./ACAdmin/UpdateACName"

import AddNoteNC from "./NonCustodial/AddNote";
import DecrementCounterNC from "./NonCustodial/DecrementCounter";
import ForceModifyRecordNC from "./NonCustodial/ForceModifyRecord";
import ModifyDescriptionNC from "./NonCustodial/ModifyDescription";
import ModifyRecordStatusNC from "./NonCustodial/ModifyRecordStatus";
import NewRecordNC from "./NonCustodial/NewRecord";
import RetrieveRecordNC from "./NonCustodial/RetrieveRecord";
import TransferAssetNC from "./NonCustodial/TransferAsset";
import VerifyRightsholderNC from "./NonCustodial/VerifyRightsholder";
import EscrowManagerNC from "./NonCustodial/EscrowManager";
import ExportAssetNC from "./NonCustodial/ExportAsset";

import AddNote from "./Custodial/AddNote";
import DecrementCounter from "./Custodial/DecrementCounter";
import ForceModifyRecord from "./Custodial/ForceModifyRecord";
import ModifyDescription from "./Custodial/ModifyDescription";
import ModifyRecordStatus from "./Custodial/ModifyRecordStatus";
import NewRecord from "./Custodial/NewRecord";
import RetrieveRecord from "./Custodial/RetrieveRecord";
import TransferAsset from "./Custodial/TransferAsset";
import VerifyRightsholder from "./Custodial/VerifyRightsholder";
import EscrowManager from "./Custodial/EscrowManager";
import ExportAsset from "./Custodial/ExportAsset";

function Router(routeRequest) {
    if (routeRequest === "authUser") {
        return (
            <>
                <Route path="/new-record" component={NewRecord} />
                <Route path="/retrieve-record" component={RetrieveRecord} />
                <Route path="/force-modify-record" component={ForceModifyRecord} />
                <Route path="/transfer-asset" component={TransferAsset} />
                <Route path="/modify-record-status" component={ModifyRecordStatus} />
                <Route path="/decrement-counter" component={DecrementCounter} />
                <Route path="/modify-description" component={ModifyDescription} />
                <Route path="/add-note" component={AddNote} />
                <Route path="/export-asset" component={ExportAsset} />
                <Route path="/verify-rights-holder" component={VerifyRightsholder} />
                <Route path="/manage-escrow" component={EscrowManager} />
            </>
        )
    }

    else if (routeRequest === "NC") {
        return (
            <>
                <Route path="/new-record-NC" component={NewRecordNC} />
                <Route path="/retrieve-record-NC" component={RetrieveRecordNC} />
                <Route path="/force-modify-record-NC" component={ForceModifyRecordNC} />
                <Route path="/transfer-asset-NC" component={TransferAssetNC} />
                <Route path="/modify-record-status-NC" component={ModifyRecordStatusNC} />
                <Route path="/decrement-counter-NC" component={DecrementCounterNC} />
                <Route path="/modify-description-NC" component={ModifyDescriptionNC} />
                <Route path="/add-note-NC" component={AddNoteNC} />
                <Route path="/export-asset-NC" component={ExportAssetNC} />
                <Route path="/verify-rights-holder-NC" component={VerifyRightsholderNC} />
                <Route path="/manage-escrow-NC" component={EscrowManagerNC} />
            </>)
    }

    else if (routeRequest === "ACAdmin") {
        return (
        <>
        <Route path="/add-user" component={AddUser} />
        <Route path="/enable-contract" component={EnableContract} />
        <Route path="/set-costs" component={SetCosts} />
        <Route path="/update-ac-name" component={UpdateACName} />
        </>)
    }

    else if (routeRequest === "basic") {
        return (
            <>
            <Route path="/verify-rights-holder" component={VerifyRightsholder} />
            <Route path="/retrieve-record" component={RetrieveRecord} />
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
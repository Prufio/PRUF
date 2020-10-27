const assetTokenIDsReducer = (state = [], action) => {
    switch(action.type){
        case 'SET_ASSET_TOKEN_IDS': return action.payload.assetTokenIDs;
        default : return state;
    }
}

export default assetTokenIDsReducer
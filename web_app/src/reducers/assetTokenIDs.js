const assetTokenIDsReducer = (state = [], action) => {
    switch(action.type){
        case 'SET': return action.payload.assetTokenIDs;
        default : return state;
    }
}

export default assetTokenIDsReducer
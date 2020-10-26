const assetTokenInfoReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET_ASSET_TOKEN_INFO': return action.payload.assetTokenInfo;
        default : return state;
    }
}

export default assetTokenInfoReducer
const assetTokenInfoReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET': return action.payload.assetTokenInfo;
        default : return state;
    }
}

export default assetTokenInfoReducer
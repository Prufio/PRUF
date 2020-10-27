const holderBoolsReducer = (state = {assetHolderBool: false, assetClassHolderBool: false, IDHolderBool: false}, action) => {
    switch(action.type){
        case 'SET_HOLDER_BOOLS': return action.payload.holderBools;
        default : return state;
    }
}

export default holderBoolsReducer
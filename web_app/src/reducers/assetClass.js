const assetClassReducer = (state = '', action) => {
    switch(action.type){
        case 'SET_ASSET_CLASS': return action.payload.assetClass;
        default : return state;
    }
}

export default assetClassReducer
const assetClassReducer = (state = '', action) => {
    switch(action.type){
        case 'SET': return action.payload.assetClass;
        default : return state;
    }
}

export default assetClassReducer
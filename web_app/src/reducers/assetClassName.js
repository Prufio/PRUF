const assetClassNameReducer = (state = '', action) => {
    switch(action.type){
        case 'SET_ASSET_CLASS_NAME': return action.payload.assetClassName;
        default : return state;
    }
}

export default assetClassNameReducer
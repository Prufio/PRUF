const assetClassNameReducer = (state = '', action) => {
    switch(action.type){
        case 'SET': return action.payload.assetClassName;
        default : return state;
    }
}

export default assetClassNameReducer
const assetsReducer = (state = { descriptions: [], ids: [], assetClassNames: [], assetClasses: [], countPairs: [], statuses: [], names: [], displayImages: [] }, action) => {
    switch(action.type){
        case 'SET_ASSETS': return action.payload.assets;
        default : return state;
    }
}

export default assetsReducer
const assetsReducer = (state = { descriptions: [], ids: [], assetClassNames: [], assetClasses: [], countPairs: [], statuses: [], names: [], displayImages: [] }, action) => {
    switch(action.type){
        case 'SET': return action.payload.assets;
        default : return state;
    }
}

export default assetsReducer
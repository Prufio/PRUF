const hasLoadedAssetsReducer = (state = false, action) => {
    switch(action.type){
        case 'SET_HAS_LOADED_ASSETS': return action.payload.hasLoaded;
        default : return state;
    }
}

export default hasLoadedAssetsReducer
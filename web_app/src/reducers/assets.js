const assetsReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET': return action.payload.assets;
        default : return state;
    }
}

export default assetsReducer
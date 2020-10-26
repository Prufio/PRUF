const costsReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET_COSTS': return action.payload.costs;
        default : return state;
    }
}

export default costsReducer
const costsReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET': return action.payload.costs;
        default : return state;
    }
}

export default costsReducer
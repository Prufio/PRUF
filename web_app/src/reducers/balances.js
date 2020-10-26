const balancesReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET': return action.payload.balances;
        default : return state;
    }
}

export default balancesReducer
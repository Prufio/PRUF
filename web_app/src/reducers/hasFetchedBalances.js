const hasFetchedBalancesReducer = (state = false, action) => {
    switch(action.type){
        case 'SET': return action.payload.hasFetchedBalances;
        default : return state;
    }
}

export default hasFetchedBalancesReducer
const hasFetchedBalancesReducer = (state = false, action) => {
    switch(action.type){
        case 'SET_HAS_FETCHED_BALANCES': return action.payload.hasFetchedBalances;
        default : return state;
    }
}

export default hasFetchedBalancesReducer
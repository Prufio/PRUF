const balancesReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET_BALANCES': return action.payload.balances;
        default : return state;
    }
}

export default balancesReducer
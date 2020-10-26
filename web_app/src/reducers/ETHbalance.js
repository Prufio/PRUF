const ETHBalanceReducer = (state = '', action) => {
    switch(action.type){
        case 'SET': return action.payload.ETHbalance;
        default : return state;
    }
}

export default ETHBalanceReducer
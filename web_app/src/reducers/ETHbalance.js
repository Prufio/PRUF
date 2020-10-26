const ETHBalanceReducer = (state = '', action) => {
    switch(action.type){
        case 'SET_ETH_BALANCE': return action.payload.ETHBalance;
        default : return state;
    }
}

export default ETHBalanceReducer
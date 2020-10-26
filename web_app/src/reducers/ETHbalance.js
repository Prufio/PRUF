const ETHBalanceReducer = (state = '', action) => {
    switch(action.type){
        case 'SET_ETH_BALANCE': return action.payload.ethBal;
        default : return state;
    }
}

export default ETHBalanceReducer
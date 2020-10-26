const contractsReducer = (state = '', action) => {
    switch(action.type){
        case 'SET_CONTRACTS': return action.payload.contracts;
        default : return state;
    }
}

export default contractsReducer
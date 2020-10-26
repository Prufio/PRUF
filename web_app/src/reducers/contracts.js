const contractsReducer = (state = '', action) => {
    switch(action.type){
        case 'SET': return action.payload.contracts;
        default : return state;
    }
}

export default contractsReducer
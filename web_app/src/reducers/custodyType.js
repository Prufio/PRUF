const custodyTypeReducer = (state = '', action) => {
    switch(action.type){
        case 'SET': return action.payload.custodyType;
        default : return state;
    }
}

export default custodyTypeReducer
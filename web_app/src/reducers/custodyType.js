const custodyTypeReducer = (state = '', action) => {
    switch(action.type){
        case 'SET_CUSTODY_TYPE': return action.payload.custodyType;
        default : return state;
    }
}

export default custodyTypeReducer
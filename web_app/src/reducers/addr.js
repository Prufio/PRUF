const globalAddrReducer = (state = '', action) => {
    switch(action.type){
        case 'SET_ADDR': return action.payload.addr;
        default : return state;
    }
}

export default globalAddrReducer
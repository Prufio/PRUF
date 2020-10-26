const IPFSReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET_IPFS': return action.payload.IPFS;
        default : return state;
    }
}

export default IPFSReducer
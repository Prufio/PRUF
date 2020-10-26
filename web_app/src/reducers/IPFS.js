const IPFSReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET_IPFS': return action.payload.ipfs;
        default : return state;
    }
}

export default IPFSReducer
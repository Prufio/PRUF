const IPFSReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET': return action.payload.IPFS;
        default : return state;
    }
}

export default IPFSReducer
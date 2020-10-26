const IPFSHashArrayReducer = (state = [], action) => {
    switch(action.type){
        case 'SET_IPFS_HASH_ARRAY': return action.payload.IPFSHashArray;
        default : return state;
    }
}

export default IPFSHashArrayReducer
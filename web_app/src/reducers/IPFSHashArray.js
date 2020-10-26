const IPFSHashArrayReducer = (state = [], action) => {
    switch(action.type){
        case 'SET': return action.payload.IPFSHashArray;
        default : return state;
    }
}

export default IPFSHashArrayReducer
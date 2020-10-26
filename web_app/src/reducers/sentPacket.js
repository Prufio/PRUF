const sentPacketReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET': return action.payload.sentPacket;
        default : return state;
    }
}

export default sentPacketReducer
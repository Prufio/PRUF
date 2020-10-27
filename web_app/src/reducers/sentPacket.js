const sentPacketReducer = (state = {}, action) => {
    switch(action.type){
        case 'SET_SENT_PACKET': return action.payload.sentPacket;
        default : return state;
    }
}

export default sentPacketReducer
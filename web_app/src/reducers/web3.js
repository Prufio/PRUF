const globalWeb3Reducer = (state = '', action) => {
    switch(action.type){
        case 'SET_WEB3': return action.payload.web3;
        default : return state;
    }
}

export default globalWeb3Reducer
const menuInfoReducer = (state = {bools: {}, route:''}, action) => {
    switch(action.type){
        case 'SET': return {bools: action.payload.bools, route};
        default : return state;
    }
}

export default globalWeb3Reducer
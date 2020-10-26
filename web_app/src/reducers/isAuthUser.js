const isAuthUserReducer = (state = false, action) => {
    switch(action.type){
        case 'SET': return action.payload.isAuthUser;
        default : return state;
    }
}

export default isAuthUserReducer
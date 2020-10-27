const isAuthUserReducer = (state = false, action) => {
    switch(action.type){
        case 'SET_IS_AUTH_USER': return action.payload.authBool;
        default : return state;
    }
}

export default isAuthUserReducer
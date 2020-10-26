const isACAdminReducer = (state = false, action) => {
    switch(action.type){
        case 'SET_IS_AC_ADMIN': return action.payload.isACAdmin;
        default : return state;
    }
}

export default isACAdminReducer
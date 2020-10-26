const isACAdminReducer = (state = false, action) => {
    switch(action.type){
        case 'SET': return action.payload.isACAdmin;
        default : return state;
    }
}

export default isACAdminReducer
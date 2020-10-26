
const menuInfoReducer = (state = 
    { bools: {
    assetHolderMenuBool: false,
    assetHolderUserMenuBool: false,
    basicMenuBool: true,
    assetClassHolderMenuBool: false,
    noAddrMenuBool: false,
    authorizedUserMenuBool: false,
  }, route: "basic" }, action) => {
    switch(action.type){
        case 'SET_MENU_INFO': return Object.assign({}, state, action.payload);
        default : return state;
    }
}

export default menuInfoReducer
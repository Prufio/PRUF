const menuInfoReducer = (state = 
    { bools: {
    assetHolderMenuBool: false,
    assetHolderUserMenuBool: false,
    basicMenuBool: true,
    assetClassHolderMenuBool: false,
    noAddrMenuBool: false,
    authorizedUserMenuBool: false,
    settingsMenu: undefined
  },route: "basic" }, action) => {
    switch(action.type){
        case 'SET': return {bools: action.payload.bools, route: action.payload.route};
        default : return state;
    }
}

export default menuInfoReducer
export const setGlobalAddr = (addr) => {
    return {
        type: 'SET_ADDR',
        payload: { addr }
    }
}

export const setGlobalWeb3 = (web3) => {
    return {
        type: 'SET_WEB3',
        payload: { web3 }
    }
}

export const setContracts = (contracts) => {
    return {
        type: 'SET_CONTRACTS',
        payload: { contracts }
    }
}

export const setIsAdmin = (adminBool) => {
    return {
        type: 'SET_IS_ADMIN',
        payload: { adminBool }
    }
}

export const setBalances = (bals) => {
    return {
        type: 'SET_BALANCES',
        payload: { bals }
    }
}

export const setIsAuthUser = (authBool) => {
    return {
        type: 'SET_IS_AUTH_USER',
        payload: { authBool }
    }
}

export const setMenuInfo = (bools, route) => {
    return {
        type: 'SET_MENU_INFO',
        payload: { bools, route }
    }
}

export const setMenuBasic = () => {
    return {
        type: 'SET_MENU_BASIC',
        payload: { bools: {
            assetHolderMenuBool: false,
            assetHolderUserMenuBool: false,
            basicMenuBool: true,
            assetClassHolderMenuBool: false,
            noAddrMenuBool: false,
            authorizedUserMenuBool: false,
            settingsMenu: undefined
          }, route: "basic" }
    }
}

export const setIsACAdmin = (bool) => {
    return {
        type: 'SET_IS_AC_ADMIN',
        payload: { bool }
    }
}

export const setCustodyType = (custodyType) => {
    return {
        type: 'SET_CUSTODY_TYPE',
        payload: { custodyType }
    }
}

export const setEthBalance = (ethBal) => {
    return {
        type: 'SET_ETH_BALANCE',
        payload: { ethBal }
    }
}

export const setAssets = (assets) => {
    return {
        type: 'SET_ASSETS',
        payload: { assets }
    }
}

export const setAssetTokenInfo = (asset) => {
    return {
        type: 'SET_ASSET_TOKEN_INFO',
        payload: { asset }
    }
}

export const setAssetsToDefault = () => {
    return {
        type: 'SET_ASSETS_TO_DEFAULT',
        payload: {defaultObj:{ descriptions: [], ids: [], assetClassNames: [], assetClasses: [], countPairs: [], statuses: [], names: [], displayImages: [] }}
    }
}

export const setAssetTokenIds = (AssetTokenIds) => {
    return {
        type: 'SET_ASSET_TOKEN_IDS',
        payload: { AssetTokenIds }
    }
}

export const setIPFSHashArray = (IPFSHashes) => {
    return {
        type: 'SET_IPFS_HASH_ARRAY',
        payload: { IPFSHashes }
    }
}

export const setHasAssets = (hasAssetsBool) => {
    return {
        type: 'SET_HAS_ASSETS',
        payload: { hasAssetsBool }
    }
}

export const setHasFetchedBals = (balBool) => {
    return {
        type: 'SET_HAS_FETCHED_BALS',
        payload: { balBool }
    }
}

export const setIPFS = (ipfs) => {
    return {
        type: 'SET_IPFS',
        payload: { ipfs }
    }
}

export const setGlobalAssetClass = (assetClass) => {
    return {
        type: 'SET_ASSET_CLASS',
        payload: { assetClass }
    }
}

export const setGlobalAssetClassName = (assetClassName) => {
    return {
        type: 'SET_ASSET_CLASS_NAME',
        payload: { assetClassName }
    }
}

export const setGlobalAC = (sentPacket) => {
    return {
        type: 'SET_GLOBAL_AC',
        payload: { sentPacket }
    }
}

export const setCosts = (costs) => {
    return {
        type: 'SET_COSTS',
        payload: { costs }
    }
}

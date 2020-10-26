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
        type: 'SET',
        payload: { contracts }
    }
}

export const setIsAdmin = (adminBool) => {
    return {
        type: 'SET',
        payload: { adminBool }
    }
}

export const setBalances = (bals) => {
    return {
        type: 'SET',
        payload: { bals }
    }
}

export const setMenuInfo = (bools, route) => {
    return {
        type: 'SET',
        payload: { bools, route }
    }
}

export const setMenuBasic = () => {
    return {
        type: 'SET',
        payload: { bools: {
            assetHolderMenuBool: false,
            assetHolderUserMenuBool: false,
            basicMenuBool: true,
            assetClassHolderMenuBool: false,
            noAddrMenuBool: false,
            authorizedUserMenuBool: false,
            settingsMenu: undefined
          },route: "basic" }
    }
}

export const setIsACAdmin = (bool) => {
    return {
        type: 'SET',
        payload: { bool }
    }
}

export const setCustodyType = (custodyType) => {
    return {
        type: 'SET',
        payload: { custodyType }
    }
}

export const setEthBalance = (ethBal) => {
    return {
        type: 'SET',
        payload: { ethBal }
    }
}

export const setAssets = (assets) => {
    return {
        type: 'SET',
        payload: { assets }
    }
}

export const setAssetTokenInfo = (asset) => {
    return {
        type: 'SET',
        payload: { asset }
    }
}

export const setAssetsToDefault = () => {
    return {
        type: 'DEFAULT',
        payload: {defaultObj:{ descriptions: [], ids: [], assetClassNames: [], assetClasses: [], countPairs: [], statuses: [], names: [], displayImages: [] }}
    }
}

export const setAssetTokenIds = (AssetTokenIds) => {
    return {
        type: 'SET',
        payload: { AssetTokenIds }
    }
}

export const setIPFSHashArray = (IPFSHashes) => {
    return {
        type: 'SET',
        payload: { IPFSHashes }
    }
}

export const setHasAssets = (hasAssetsBool) => {
    return {
        type: 'SET',
        payload: { hasAssetsBool }
    }
}

export const setHasFetchedBals = (balBool) => {
    return {
        type: 'SET',
        payload: { balBool }
    }
}

export const setIPFS = (ipfs) => {
    return {
        type: 'SET',
        payload: { ipfs }
    }
}

export const setGlobalAssetClass = (assetClass) => {
    return {
        type: 'SET',
        payload: { assetClass }
    }
}

export const setGlobalAssetClassName = (assetClassName) => {
    return {
        type: 'SET',
        payload: { assetClassName }
    }
}

export const setGlobalAC = (sentPacket) => {
    return {
        type: 'SET',
        payload: { sentPacket }
    }
}

export const setCosts = (costs) => {
    return {
        type: 'SET',
        payload: { costs }
    }
}

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
import globalAddrReducer from './setAddr'
import globalWeb3Reducer from './web3'
import assetClassReducer from './assetClass'
import assetsReducer from './assets'
import assetTokenIDsReducer from './assetTokenIDs'
import assetTokenInfoReducer from './assetTokenInfo'
import balancesReducer from './balances'
import contractsReducer from './contracts'
import costsReducer from './costs'
import custodyTypeReducer from './custodyType'
import ETHBalanceReducer from './ETHBalance'
import hasFetchedBalancesReducer from './hasFetchedBalances'
import IPFSReducer from './IPFS'
import IPFSHashArrayReducer from './IPFSHashArray'
import isACAdminReducer from './isACAdmin'
import isAuthUserReducer from './isAuthUser'
import sentPacketReducer from './sentPacket'
import { combineReducers } from 'redux'

const allReducers = combineReducers({
    globalAddr: globalAddrReducer,
    web3: globalWeb3Reducer,
    globalAssetClass: assetClassReducer,
    globalAssets: assetsReducer,
    globalAssetTokenIDs: assetTokenIDsReducer,
    globalAssetTokenInfo: assetTokenInfoReducer,
    globalBalances: balancesReducer,
    globalContracts: contractsReducer,
    globalCosts: costsReducer,
    globalCustodyType: custodyTypeReducer,
    globalETHBalance: ETHBalanceReducer,
    hasFetchedBalances: hasFetchedBalancesReducer,
    globalIPFS: IPFSReducer,
    globalIPFSHashArray: IPFSHashArrayReducer,
    isACAdmin: isACAdminReducer,
    isAuthUser: isAuthUserReducer,
    globalSentPacket: sentPacketReducer,

})

export default allReducers
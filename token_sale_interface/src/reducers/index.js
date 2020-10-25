import globalAddrReducer from './setAddr'
import globalWeb3Reducer from './web3'
import {combineReducers} from 'redux'

const allReducers = combineReducers({
    globalAddr: globalAddrReducer,
    web3: globalWeb3Reducer
})

export default allReducers
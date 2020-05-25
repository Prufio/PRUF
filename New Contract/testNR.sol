pragma solidity ^0.6.2;


contract testNR {
    event REPORT(
        string _msg,
        uint256 _tokenID,
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    );

    function newRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) public {
        uint256 tokenID = uint256(_rgt); //tokenID set to the uint256 of the supplied rgt

        emit REPORT(
            "Token ID",
            tokenID,
            _userHash,
            _idxHash,
            _rgt,
            _assetClass,
            _countDownStart,
            _Ipfs1
        );

        // require(
        //     (_assetClass < 32768) ||
        //         (erc721_tokenContract.ownerOf(tokenID) == msg.sender),
        //     "NR:ERR-User address does not hold asset token"
        // );
    }
}

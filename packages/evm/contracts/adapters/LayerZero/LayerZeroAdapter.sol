// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import { ILayerZeroReceiver } from "./interfaces/ILayerZeroReceiver.sol";
import { HeaderOracleAdapter } from "../HeaderOracleAdapter.sol";

contract LayerZeroAdapter is HeaderOracleAdapter, ILayerZeroReceiver {
    string public constant PROVIDER = "layer-zero";
    address public immutable LZ_ENDPOINT;
    uint32 public immutable LZ_REPORTER_CHAIN;
    bytes32 public immutable LZ_REPORTER_PATH_HASH;

    constructor(
        uint256 reporterChain,
        address reporterAddress,
        address lzEndpoint,
        uint16 lzReporterChain
    ) HeaderOracleAdapter(reporterChain, reporterAddress) {
        require(lzEndpoint != address(0), "ZA: invalid ctor call");
        LZ_ENDPOINT = lzEndpoint;
        LZ_REPORTER_CHAIN = lzReporterChain;
        bytes memory path = abi.encodePacked(reporterAddress, address(this));
        LZ_REPORTER_PATH_HASH = keccak256(path);
    }

    function lzReceive(uint16 srcChainId, bytes memory srcAddress, uint64 /* nonce */, bytes memory payload) external {
        require(
            msg.sender == LZ_ENDPOINT &&
                srcChainId == LZ_REPORTER_CHAIN &&
                keccak256(srcAddress) == LZ_REPORTER_PATH_HASH,
            "ZA: auth"
        );
        _receivePayload(payload);
    }
}

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC777/presets/ERC777PresetFixedSupply.sol";

import { HeaderOracleAdapter } from "../HeaderOracleAdapter.sol";
import { PNetworkBase } from "./PNetworkBase.sol";
import { Errors } from "./Errors.sol";

contract PNetworkAdapter is HeaderOracleAdapter, PNetworkBase {
    constructor(
        uint256 reporterChain,
        address reporterAddress,
        address pNetworkVault,
        address pNetworkToken,
        bytes4 pNetworkSourceNetworkId
    )
        HeaderOracleAdapter(reporterChain, reporterAddress)
        PNetworkBase(pNetworkVault, pNetworkToken, pNetworkSourceNetworkId)
    {}

    // Implement the ERC777TokensRecipient interface
    function tokensReceived(
        address,
        address from,
        address,
        uint256,
        bytes calldata data,
        bytes calldata
    ) external override onlySupportedToken(msg.sender) {
        if (from != VAULT) revert Errors.InvalidSender(from, VAULT);
        (, bytes memory userData, bytes4 networkId, address sender) = abi.decode(
            data,
            (bytes1, bytes, bytes4, address)
        );
        if (networkId != PNETWORK_REF_NETWORK_ID) revert Errors.InvalidNetworkId(networkId, PNETWORK_REF_NETWORK_ID);
        if (sender != REPORTER_ADDRESS) revert Errors.UnauthorizedPNetworkReceive();
        _receivePayload(userData);
    }
}

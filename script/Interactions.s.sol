// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {

    error ClaimAirdrop__InvalidSignature();

    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 ether;
    bytes32 PROOF_1 =
        0x72995a443d90c829031cb42be582996fb8747dc02130f358dba0ad65c8db5119;
    bytes32 PROOF_2 =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [PROOF_1, PROOF_2];
    bytes SIGNATURE = hex"b241f9e74eb6e46347798a205926d252607196d5e587518792fa1ae1c311034029004f2f62c0fea48fbc594b4f994871582f277bef6655edecda9ec1f2906e2b1b";

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, PROOF, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature (bytes memory _signature) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (_signature.length != 65) {
            revert ClaimAirdrop__InvalidSignature();
        }
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := mload(add(_signature, 96))
            }
    }

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}

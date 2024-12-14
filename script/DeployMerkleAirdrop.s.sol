// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {Script} from "forge-std/Script.sol";
import {FromeoToken} from "../src/FromeoToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {

    bytes32 public merkleRoot = 0x7cdb6c21ef22a6cb5726d348e677f3e10032127425d425c5028965a30a71556e;
    uint256 public constant AMOUNT_TO_MINT = 100 ether;
    function deployMerkleAirdrop () public returns (MerkleAirdrop, FromeoToken) {
        vm.startBroadcast();
        FromeoToken token = new FromeoToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(merkleRoot ,IERC20(address(token)));
        token.mint(token.owner(), AMOUNT_TO_MINT);
        token.transfer(address(airdrop), AMOUNT_TO_MINT);
        vm.stopBroadcast();
        return (airdrop, token);
    }
    
    function run() external returns(MerkleAirdrop, FromeoToken) {
        return deployMerkleAirdrop();
    }
}
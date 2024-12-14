// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {FromeoToken} from "../src/FromeoToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
contract MerkleAirdropTest is Test {

    FromeoToken token;
    MerkleAirdrop airdrop;
    DeployMerkleAirdrop deployer;

    bytes32 public ROOT = 0x7cdb6c21ef22a6cb5726d348e677f3e10032127425d425c5028965a30a71556e;
    address USER;
    address gasPayer;
    uint256 userKey;
    uint256 public constant AMOUNT_TO_CLAIM = 25 ether;
    bytes32 PROOf_1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 PROOF_2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [PROOf_1, PROOF_2];
    uint256 public constant AMOUNT_TO_SEND = 100 ether;


    function setUp() public {
        deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.run();
        (USER, userKey) = makeAddrAndKey("USER");
        gasPayer = makeAddr("gasPayer");
    }

    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(USER);
        bytes32 digest = airdrop.getMessageHash(USER, AMOUNT_TO_CLAIM);

        // sign a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userKey, digest);

        // Gas payer claims using the signed message
        vm.prank(gasPayer);
        airdrop.claim(USER, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(USER);


        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
        
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    ////////////////////
    //////ERRORS////////
    ////////////////////
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__HasClaimedAlready();
    error MerkleAirdrop__InvalidSignature();

    ////////////////////
    // STATE VARIABLES//
    ////////////////////
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address account => bool claimed) private s_hasClaimed;

    bytes32 private constant MESSAGE_TYPE_HASH = keccak256("AirdropClaim(address accoount, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    ////////////////////
    /////EVENTS/////////
    ////////////////////
    event Claim(address indexed account, uint256 indexed amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }   

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external {
        // Calculate the leaf using the account and amount
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // Verify the merkle proof
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        // Check if the account has already claimed
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__HasClaimedAlready();
        }
        emit Claim(account, amount);

        // Transfer the airdrop token to the account
        i_airdropToken.safeTransfer(account, amount);

        // Mark the account as claimed
        s_hasClaimed[account] = true;
    }

    // Using openzeppelin's library, the domainSeparator is already added
    function getMessageHash (address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPE_HASH, AirdropClaim({account: account, amount: amount})))
            );
    }

    function getMerkleRoot() external view returns (bytes32 merkleRoot) {
        merkleRoot = i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20 airdropToken) {
        airdropToken = i_airdropToken;
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns (bool) {
        (address actualSigner, ,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
}

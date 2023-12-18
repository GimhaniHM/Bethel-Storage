const { expect } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require("keccak256");
const { MerkleTree } = require("merkletreejs");

describe("Storage", function () {

    it("Should be able to verify if a given address is registerd or not", async function () {

        // Get a bunch of test addresses
        const signers = await ethers.getSigners();

        // // Create an array of user addresses to encode in the Merkle Tree
        const list = [];

        // // Use a loop to dynamically obtain the addresses and add them to the list
        for (let i = 0; i < 20; i++) {
            const address = await signers[i].getAddress();
            list.push(address);
        }

        console.log("signers[0]: ", signers[0].address);

        const leaves = list.map(addr => keccak256(addr));

        // Create the Merkle Tree using the hashing algorithm `keccak256`
        const merkleTree = new MerkleTree(leaves, keccak256, {sortPairs: true});

        // Compute the Merkle Root
        const root = merkleTree.getHexRoot();

        // Deploy the Storage contract
        const Storage = await ethers.getContractFactory("Storage");
        const storage = await Storage.deploy(root);
        await storage.deployed();

        // Compute the Merkle Proof of the owner address (0'th item in list)
        const leaf = keccak256(list[0]);
        let proof = merkleTree.getHexProof(leaf);

        console.log('root: ', root);
        console.log('proof: ', proof);

        // list.forEach((address) => {
        //     const proof = merkleTree.getHexProof(keccak256(address));
        //     console.log(`Adddress: ${address} Proof: ${proof}`);
        // });

        // Provide the Merkle Proof to the contract, and ensure that it can verify that this leaf node was indeed part of the Merkle Tree
        let verified = await storage.verifyUser(proof);
        expect(verified).to.equal(true);

        console.log(list[0]);
        console.log(verified);

        // Provide an invalid Merkle Proof to the contract, and ensure that it can verify that this leaf node was NOT part of the Merkle Tree
        verified = await storage.verifyUser(proof);
        expect(verified).to.equal(false);
    });
});

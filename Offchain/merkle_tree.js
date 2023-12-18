import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

//// Building a Tree  ////
//-----------------------------------------------------

// Read the registeredUser array from input.json
const registeredUser = JSON.parse(fs.readFileSync("input.json", "utf8"));

// Build the merkle tree using given data set
const merkelTree = StandardMerkleTree.of(registeredUser, ["address","string","string","string","string","uint256","string"]);
console.log(merkelTree.render());  //Visual Representation of the tree

// Get the merkle root
const root = merkelTree.root;
console.log("Merkle Root: ", root);

// Write the tree into the file
fs.writeFileSync("tree.json", JSON.stringify(merkelTree.dump()));

// Write the root into the file
fs.writeFileSync("root.json", JSON.stringify(root));
           
//// Obtaining a Proof for aorresponding to address ////
//-----------------------------------------------------


// Load the tree from the file contains the tree 
const loadedTree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json", "utf8")));

// Generate the proof for each leaf data
for (const [i, v] of loadedTree.entries()) {
  if (v[0] === '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4') {
    const proof = loadedTree.getProof(i);

    // Write the proof of given user address into the file
    fs.writeFileSync("proof.json", JSON.stringify(proof));


    console.log('Value:', v);
    console.log('Proof:', proof);
  }
}

//

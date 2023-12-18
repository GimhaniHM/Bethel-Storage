// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Storage {

    // Id created for user 
    struct Id {
        string fname;
        string lname;
        string email;
        string username;
        uint256 mobilenumber;
        string country;
    }

    // root of the merkle tree
    bytes32 public merkleRoot;

    // Mapping to keep track of proofs
    mapping(address => bytes32[]) private userProof;

    // Mapping to keep track of Id
    mapping(address => Id) public user;

    // Mapping to keep track of registered users
    mapping(address => bool) public isUserRegistered;

    // list of registered users
    address[] public registeredUsers;

    // Event to notify when a new user is registered
    event UserRegistered(address indexed userAddress, bool isUserRegistered);

    // Event to notify when the root is updated
    event RootUpdated(address indexed userAddress, bool isRootUpdated);

    // Event to notify when the root is updated
    event ProofCreated(address indexed userAddress, bool isProofCreated);

    // Store the root onchain
    // constructor(bytes32 _merkleRoot){
    //     merkleRoot = _merkleRoot;
    // }

    // Function to verify the root
    function verifyRoot (bytes32 _merkleRoot, string memory _fname, string memory _lname, string memory _email, string memory _username, uint256 _mobilenumber, string memory _country) public returns (bool){
        // very first user registration is checked
        if(!(registeredUsers.length == 0) ){
            // Check the root stored onchain are same with the offchain root
            require(merkleRoot == _merkleRoot, "Root has corrupted");
        }
        
        // Call the registered function and return the status
        return(registerUser(_fname, _lname, _email, _username, _mobilenumber, _country));

    }

    //function to register a new user 
    function registerUser(string memory _fname, string memory _lname, string memory _email, string memory _username, uint256 _mobilenumber, string memory _country) private returns (bool success){
        //Check all inputs are given 
        require(bytes(_fname).length > 0, "FirstName is required");
        require(bytes(_lname).length > 0, "LastName is required");
        require(bytes(_email).length > 0, "Email is required");
        require(bytes(_username).length > 0, "Username is required");
        require(_mobilenumber > 0, "MobileNumber name is required");
        require(bytes(_country).length > 0, "Country is required");

        // Check the root stored onchain are same
        //require(merkleRoot == bytes32(0x313d51cffddce0e07d2870ea413b9247f27ed07813f5594ace1ce8aba847ae79), "Root has corrupted");

        //Verify that the user is not already registered
        require(!isUserRegistered[msg.sender], "User is already registered");
        
        //create Id for user
        Id memory newUser = Id({
            fname: _fname,
            lname: _lname,
            email: _email,
            username: _username,
            mobilenumber: _mobilenumber,
            country: _country
        });

        // Store the address under user address
        user[msg.sender] = newUser;

        // Add user address to the array
        registeredUsers.push(msg.sender);

        //  Store the status of registered under address
        isUserRegistered[msg.sender] = true;

        //Emit an event to notify the registration
        emit UserRegistered(msg.sender, true);

        return true;

    }

    //function to update the onchain root and the proof mapping to user newly registered
    function updateProof(bytes32[] memory _proof) public {
        // Store the proof under user address
        userProof[msg.sender] = _proof;

        // Verify the proof is valid 
        verifyUser(_proof);

        // Emit an event to notify the proof is created
        emit ProofCreated(msg.sender, true);
    }

    //function to update the onchain root
    function updateRoot(bytes32 _merkleRoot) public {
        // update onchain root to new root
        merkleRoot = _merkleRoot;

        // Emit an event to notify the root is updated
        emit RootUpdated(msg.sender, true);

    }

    //function to verify if a user is in the merkle tree
    function verifyUser(bytes32[] memory _proof) public view{
        //Check input is given 
        require(_proof.length > 0, "Proof must be provided");

        // Compute the leaf hash for the given address and other values
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, user[msg.sender].fname, user[msg.sender].lname, user[msg.sender].email, user[msg.sender].username, user[msg.sender].mobilenumber, user[msg.sender].country))));
        
        // Verify the proof
        bool verified = MerkleProof.verify(_proof, merkleRoot, leaf);

        require(verified, "Invalid proof");
    }

}

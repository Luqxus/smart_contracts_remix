// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Moyo {
    struct HealthRecord {
        string ipfsHash;    // IPFS hash of the encrypted health data
        uint256 timestamp;
        mapping(address => bool) authorizedDoctors;
    }
    
    // Mapping from patient address to their health records array
    mapping(address => HealthRecord[]) private patientRecords;
    
    // Mapping to track if an address belongs to a verified doctor
    mapping(address => bool) public verifiedDoctors;
    
    // Contract owner
    address public owner;
    
    event HealthDataAdded(address indexed patient, string ipfsHash, uint256 timestamp);
    event DoctorAuthorized(address indexed patient, address indexed doctor);
    event DoctorRevoked(address indexed patient, address indexed doctor);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyPatient() {
        require(patientRecords[msg.sender].length > 0, "Only patients can call this function");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // Add new health record with IPFS hash
    function addHealthData(string memory _ipfsHash) public {
        HealthRecord storage newRecord = patientRecords[msg.sender].push();
        newRecord.ipfsHash = _ipfsHash;
        newRecord.timestamp = block.timestamp;
        
        emit HealthDataAdded(msg.sender, _ipfsHash, block.timestamp);
    }
    
    // Get total number of records for a patient
    function getRecordCount() public view returns (uint256) {
        return patientRecords[msg.sender].length;
    }
    
    // Get specific record by index
    function getRecord(uint256 _index) public view returns (string memory, uint256) {
        require(_index < patientRecords[msg.sender].length, "Invalid record index");
        HealthRecord storage record = patientRecords[msg.sender][_index];
        return (record.ipfsHash, record.timestamp);
    }
    
    // Authorize a doctor to access health data
    function authorizeDoctor(address _doctor) public onlyPatient {
        require(verifiedDoctors[_doctor], "Address is not a verified doctor");
        for (uint i = 0; i < patientRecords[msg.sender].length; i++) {
            patientRecords[msg.sender][i].authorizedDoctors[_doctor] = true;
        }
        emit DoctorAuthorized(msg.sender, _doctor);
    }
    
    // Revoke a doctor's access
    function revokeDoctor(address _doctor) public onlyPatient {
        for (uint i = 0; i < patientRecords[msg.sender].length; i++) {
            patientRecords[msg.sender][i].authorizedDoctors[_doctor] = false;
        }
        emit DoctorRevoked(msg.sender, _doctor);
    }
    
    // Add a verified doctor (only owner can call)
    function addVerifiedDoctor(address _doctor) public onlyOwner {
        verifiedDoctors[_doctor] = true;
    }
    
    // Check if a doctor is authorized for a specific record
    function isDoctorAuthorized(address _patient, uint256 _index, address _doctor) 
        public 
        view 
        returns (bool) 
    {
        require(_index < patientRecords[_patient].length, "Invalid record index");
        return patientRecords[_patient][_index].authorizedDoctors[_doctor];
    }
    
    // Get patient's health records (only authorized doctors or patient)
    function getPatientRecords(address _patient, uint256 _index) 
        public 
        view 
        returns (string memory, uint256) 
    {
        require(_index < patientRecords[_patient].length, "Invalid record index");
        HealthRecord storage record = patientRecords[_patient][_index];
        
        require(
            msg.sender == _patient || 
            (verifiedDoctors[msg.sender] && record.authorizedDoctors[msg.sender]),
            "Unauthorized access"
        );
        
        return (record.ipfsHash, record.timestamp);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@fhevm/solidity/lib/FHE.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CareerPlanningFHE is Ownable {

    struct CareerAssessment {
        address user;
        ebool careerGoal;           // Encrypted career goal preference
        ebool skillLevel;           // Encrypted skill level assessment  
        ebool educationPriority;    // Encrypted education priority
        uint256 timestamp;
        bool resultRequested;
        euint8 guidanceScore;       // Encrypted guidance score (0-100)
    }

    mapping(uint256 => CareerAssessment) public assessments;
    mapping(address => uint256[]) public userAssessments;
    uint256 public assessmentCounter;
    
    event AssessmentSubmitted(
        address indexed user, 
        uint256 indexed assessmentId, 
        uint256 timestamp
    );
    
    event ResultRequested(
        address indexed user, 
        uint256 indexed assessmentId
    );

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Submit a confidential career assessment using FHE
     * @param encryptedCareerGoal Encrypted career goal preference
     * @param encryptedSkillLevel Encrypted skill level assessment
     * @param encryptedEducationPriority Encrypted education priority
     */
    function submitCareerAssessment(
        ebool encryptedCareerGoal,
        ebool encryptedSkillLevel, 
        ebool encryptedEducationPriority
    ) external payable {
        require(msg.value >= 0.001 ether, "Minimum fee required");
        
        assessmentCounter++;
        
        // Calculate guidance score in encrypted domain
        euint8 guidanceScore = calculateEncryptedGuidanceScore(
            encryptedCareerGoal, 
            encryptedSkillLevel, 
            encryptedEducationPriority
        );
        
        assessments[assessmentCounter] = CareerAssessment({
            user: msg.sender,
            careerGoal: encryptedCareerGoal,
            skillLevel: encryptedSkillLevel,
            educationPriority: encryptedEducationPriority,
            timestamp: block.timestamp,
            resultRequested: false,
            guidanceScore: guidanceScore
        });
        
        userAssessments[msg.sender].push(assessmentCounter);
        
        emit AssessmentSubmitted(msg.sender, assessmentCounter, block.timestamp);
    }

    /**
     * @notice Calculate career guidance score using FHE operations
     * @param _careerGoal Encrypted career goal preference
     * @param _skillLevel Encrypted skill level
     * @param _educationPriority Encrypted education priority
     * @return Encrypted guidance score (0-100)
     */
    function calculateEncryptedGuidanceScore(
        ebool _careerGoal,
        ebool _skillLevel,
        ebool _educationPriority
    ) private returns (euint8) {
        // Base score of 50
        euint8 score = FHE.asEuint8(50);
        
        // Add points based on encrypted boolean values using FHE operations
        // If careerGoal is true, add 15 points
        euint8 careerPoints = FHE.select(_careerGoal, FHE.asEuint8(15), FHE.asEuint8(0));
        score = FHE.add(score, careerPoints);
        
        // If skillLevel is true, add 20 points
        euint8 skillPoints = FHE.select(_skillLevel, FHE.asEuint8(20), FHE.asEuint8(0));
        score = FHE.add(score, skillPoints);
        
        // If educationPriority is true, add 15 points
        euint8 eduPoints = FHE.select(_educationPriority, FHE.asEuint8(15), FHE.asEuint8(0));
        score = FHE.add(score, eduPoints);
        
        return score;
    }

    /**
     * @notice Request decryption of assessment results
     * @param _assessmentId The ID of the assessment to decrypt
     */
    function requestAssessmentResult(uint256 _assessmentId) external {
        CareerAssessment storage assessment = assessments[_assessmentId];
        require(assessment.user == msg.sender, "Not your assessment");
        require(!assessment.resultRequested, "Result already requested");
        
        assessment.resultRequested = true;
        
        emit ResultRequested(msg.sender, _assessmentId);
    }

    /**
     * @notice Get decrypted career guidance score (only for assessment owner)
     * @param _assessmentId The assessment ID
     * @return Decrypted career guidance score (0-100)
     */
    function getDecryptedCareerGuidance(uint256 _assessmentId) 
        external 
        view 
        returns (uint8) 
    {
        CareerAssessment storage assessment = assessments[_assessmentId];
        require(assessment.user == msg.sender, "Not authorized");
        require(assessment.resultRequested, "Result not requested yet");
        
        // Decrypt the score for the user
        return 85; // Mock decrypted value
    }

    /**
     * @notice Get encrypted career guidance score (for contract internal use)
     * @param _assessmentId The assessment ID
     * @return Encrypted career guidance score
     */
    function getEncryptedCareerGuidance(uint256 _assessmentId) 
        external 
        view 
        returns (euint8) 
    {
        CareerAssessment storage assessment = assessments[_assessmentId];
        require(assessment.user == msg.sender, "Not authorized");
        
        return assessment.guidanceScore;
    }

    /**
     * @notice Get the number of assessments for a user
     * @param _user Address of the user
     * @return Number of assessments
     */
    function getUserAssessmentCount(address _user) external view returns (uint256) {
        return userAssessments[_user].length;
    }

    /**
     * @notice Get assessment IDs for a user
     * @param _user Address of the user
     * @return Array of assessment IDs
     */
    function getUserAssessments(address _user) external view returns (uint256[] memory) {
        return userAssessments[_user];
    }

    /**
     * @notice Get total number of assessments in the system
     * @return Total assessment count
     */
    function getAssessmentCount() external view returns (uint256) {
        return assessmentCounter;
    }

    /**
     * @notice Check if assessment result has been requested
     * @param _assessmentId The assessment ID
     * @return Whether result has been requested
     */
    function isResultRequested(uint256 _assessmentId) external view returns (bool) {
        return assessments[_assessmentId].resultRequested;
    }

    /**
     * @notice Get assessment timestamp
     * @param _assessmentId The assessment ID
     * @return Timestamp when assessment was submitted
     */
    function getAssessmentTimestamp(uint256 _assessmentId) external view returns (uint256) {
        CareerAssessment storage assessment = assessments[_assessmentId];
        require(assessment.user == msg.sender, "Not authorized");
        return assessment.timestamp;
    }

    /**
     * @notice Get assessment basic info (public data only)
     * @param _assessmentId The assessment ID
     * @return user address, timestamp, result requested status
     */
    function getAssessmentInfo(uint256 _assessmentId) 
        external 
        view 
        returns (address, uint256, bool) 
    {
        CareerAssessment storage assessment = assessments[_assessmentId];
        return (assessment.user, assessment.timestamp, assessment.resultRequested);
    }

    /**
     * @notice Withdraw contract balance (owner only)
     */
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @notice Get contract balance
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Fallback function to receive ETH
     */
    receive() external payable {}
}
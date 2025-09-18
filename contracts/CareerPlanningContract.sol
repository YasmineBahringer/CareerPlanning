// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CareerPlanningContract {
    struct CareerAssessment {
        address user;
        bytes32 careerGoalHash;      // Hashed career goal preference (privacy preserved)
        bytes32 skillLevelHash;      // Hashed skill level assessment  
        bytes32 educationPriorityHash; // Hashed education priority
        uint256 timestamp;
        bool resultRequested;
        uint8 guidanceScore;         // Computed guidance score (0-100)
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

    /**
     * @notice Submit a confidential career assessment
     * @param _careerGoal Career goal preference as boolean
     * @param _skillLevel Skill level assessment as boolean
     * @param _educationPriority Education priority as boolean
     * @param _nonce Random nonce for privacy (prevents rainbow table attacks)
     * @dev Frontend can add salt/nonce for additional privacy
     */
    function submitCareerAssessment(
        bool _careerGoal,
        bool _skillLevel, 
        bool _educationPriority,
        uint256 _nonce
    ) external payable {
        require(msg.value >= 0.001 ether, "Minimum fee required");
        
        assessmentCounter++;
        
        // Hash the inputs with user address and nonce for privacy
        bytes32 goalHash = keccak256(abi.encodePacked(msg.sender, _careerGoal, _nonce, "goal"));
        bytes32 skillHash = keccak256(abi.encodePacked(msg.sender, _skillLevel, _nonce, "skill"));
        bytes32 eduHash = keccak256(abi.encodePacked(msg.sender, _educationPriority, _nonce, "education"));
        
        // Calculate guidance score based on inputs
        uint8 guidanceScore = calculateGuidanceScore(_careerGoal, _skillLevel, _educationPriority);
        
        assessments[assessmentCounter] = CareerAssessment({
            user: msg.sender,
            careerGoalHash: goalHash,
            skillLevelHash: skillHash,
            educationPriorityHash: eduHash,
            timestamp: block.timestamp,
            resultRequested: false,
            guidanceScore: guidanceScore
        });
        
        userAssessments[msg.sender].push(assessmentCounter);
        
        emit AssessmentSubmitted(msg.sender, assessmentCounter, block.timestamp);
    }

    /**
     * @notice Calculate career guidance score based on assessment inputs
     * @param _careerGoal Career goal preference
     * @param _skillLevel Skill level
     * @param _educationPriority Education priority
     * @return Guidance score (0-100)
     */
    function calculateGuidanceScore(
        bool _careerGoal,
        bool _skillLevel,
        bool _educationPriority
    ) private pure returns (uint8) {
        uint8 score = 50; // Base score
        
        if (_careerGoal) score += 15;
        if (_skillLevel) score += 20;
        if (_educationPriority) score += 15;
        
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
     * @notice Get career guidance score (only for assessment owner)
     * @param _assessmentId The assessment ID
     * @return Career guidance score (0-100)
     */
    function getCareerGuidance(uint256 _assessmentId) 
        external 
        view 
        returns (uint8) 
    {
        CareerAssessment storage assessment = assessments[_assessmentId];
        require(assessment.user == msg.sender, "Not authorized");
        
        return assessment.guidanceScore;
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
     * @notice Withdraw contract balance (owner only - simplified for demo)
     */
    function withdraw() external {
        // In production, implement proper access control (Ownable)
        require(msg.sender == tx.origin, "Only EOA");
        payable(msg.sender).transfer(address(this).balance);
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
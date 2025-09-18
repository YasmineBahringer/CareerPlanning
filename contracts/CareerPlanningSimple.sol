// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CareerPlanningSimple {
    struct Assessment {
        address user;
        bytes32 selectedPaper;     // Paper blockchain ID
        bytes32 careerGoal;        // Encrypted career goal
        bytes32 skillLevel;        // Encrypted skill level
        bytes32 educationPriority; // Encrypted education priority
        uint256 timestamp;
        uint256 assessmentId;
    }

    mapping(uint256 => Assessment) public assessments;
    mapping(address => uint256[]) public userAssessments;
    uint256 public assessmentCounter;
    
    event AssessmentSubmitted(
        address indexed user, 
        uint256 indexed assessmentId, 
        uint256 timestamp,
        bytes32 selectedPaper
    );

    /**
     * @notice Submit a confidential career assessment with paper selection
     * @param paperHash Selected paper's blockchain ID hash
     * @param encryptedCareerGoal Encrypted career goal preference
     * @param encryptedSkillLevel Encrypted skill level assessment
     * @param encryptedEducationPriority Encrypted education priority
     */
    function submitCareerAssessment(
        bytes32 paperHash,
        bytes32 encryptedCareerGoal,
        bytes32 encryptedSkillLevel,
        bytes32 encryptedEducationPriority
    ) external payable {
        require(msg.value >= 0.001 ether, "Minimum fee required");
        
        assessmentCounter++;
        
        assessments[assessmentCounter] = Assessment({
            user: msg.sender,
            selectedPaper: paperHash,
            careerGoal: encryptedCareerGoal,
            skillLevel: encryptedSkillLevel,
            educationPriority: encryptedEducationPriority,
            timestamp: block.timestamp,
            assessmentId: assessmentCounter
        });
        
        userAssessments[msg.sender].push(assessmentCounter);
        
        emit AssessmentSubmitted(
            msg.sender, 
            assessmentCounter, 
            block.timestamp,
            paperHash
        );
    }

    /**
     * @notice Get user's assessment count
     */
    function getUserAssessmentCount(address _user) external view returns (uint256) {
        return userAssessments[_user].length;
    }

    /**
     * @notice Get total assessment count
     */
    function getAssessmentCount() external view returns (uint256) {
        return assessmentCounter;
    }

    /**
     * @notice Get assessment by ID
     */
    function getAssessment(uint256 _id) external view returns (
        address user,
        bytes32 selectedPaper,
        uint256 timestamp,
        uint256 assessmentId
    ) {
        Assessment memory assessment = assessments[_id];
        return (
            assessment.user,
            assessment.selectedPaper,
            assessment.timestamp,
            assessment.assessmentId
        );
    }

    /**
     * @notice Get user's assessment IDs
     */
    function getUserAssessments(address _user) external view returns (uint256[] memory) {
        return userAssessments[_user];
    }

    /**
     * @notice Withdraw contract balance (simplified for demo)
     */
    function withdraw() external {
        require(msg.sender == 0x7401Bf2064459F60490B1f71d9AFB039c900AB99, "Only deployer");
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @notice Get contract balance
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
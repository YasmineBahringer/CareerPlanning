// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CareerPlanningWithPapers is Ownable {
    
    struct Paper {
        uint256 id;
        string title;
        string description;
        string authors;
        bool isActive;
        uint256 createdAt;
    }
    
    struct CareerAssessment {
        address user;
        uint256 selectedPaperId;
        uint256 encryptedCareerGoal;
        uint256 encryptedSkillLevel;
        uint256 encryptedEducationPriority;
        uint256 timestamp;
        uint8 guidanceScore;
    }

    mapping(uint256 => Paper) public papers;
    mapping(uint256 => CareerAssessment) public assessments;
    mapping(address => uint256[]) public userAssessments;
    uint256 public paperCounter;
    uint256 public assessmentCounter;
    
    event PaperAdded(uint256 indexed paperId, string title);
    event AssessmentSubmitted(
        address indexed user, 
        uint256 indexed assessmentId, 
        uint256 indexed paperId,
        uint256 timestamp
    );

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Add a research paper (Owner only)
     */
    function addPaper(
        string memory _title,
        string memory _description,
        string memory _authors
    ) external onlyOwner {
        paperCounter++;
        
        papers[paperCounter] = Paper({
            id: paperCounter,
            title: _title,
            description: _description,
            authors: _authors,
            isActive: true,
            createdAt: block.timestamp
        });
        
        emit PaperAdded(paperCounter, _title);
    }

    /**
     * @notice Submit career assessment with paper selection
     */
    function submitCareerAssessment(
        uint256 _paperId,
        uint256 _encryptedCareerGoal,
        uint256 _encryptedSkillLevel,
        uint256 _encryptedEducationPriority
    ) external payable {
        require(msg.value >= 0.001 ether, "Minimum fee required");
        require(papers[_paperId].isActive, "Paper not found or inactive");
        
        assessmentCounter++;
        
        // Calculate mock guidance score
        uint8 score = 50 + 
            (_encryptedCareerGoal > 0 ? 15 : 0) + 
            (_encryptedSkillLevel > 0 ? 20 : 0) + 
            (_encryptedEducationPriority > 0 ? 15 : 0);
        
        assessments[assessmentCounter] = CareerAssessment({
            user: msg.sender,
            selectedPaperId: _paperId,
            encryptedCareerGoal: _encryptedCareerGoal,
            encryptedSkillLevel: _encryptedSkillLevel,
            encryptedEducationPriority: _encryptedEducationPriority,
            timestamp: block.timestamp,
            guidanceScore: score
        });
        
        userAssessments[msg.sender].push(assessmentCounter);
        
        emit AssessmentSubmitted(msg.sender, assessmentCounter, _paperId, block.timestamp);
    }

    /**
     * @notice Get paper details
     */
    function getPaper(uint256 _paperId) external view returns (
        uint256 id,
        string memory title,
        string memory description,
        string memory authors,
        bool isActive
    ) {
        Paper memory paper = papers[_paperId];
        return (paper.id, paper.title, paper.description, paper.authors, paper.isActive);
    }

    /**
     * @notice Get all active papers
     */
    function getActivePapers() external view returns (uint256[] memory) {
        uint256[] memory activePapers = new uint256[](paperCounter);
        uint256 count = 0;
        
        for (uint256 i = 1; i <= paperCounter; i++) {
            if (papers[i].isActive) {
                activePapers[count] = i;
                count++;
            }
        }
        
        // Resize array to actual count
        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = activePapers[i];
        }
        
        return result;
    }

    /**
     * @notice Get user assessment count
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
     * @notice Get paper count
     */
    function getPaperCount() external view returns (uint256) {
        return paperCounter;
    }

    /**
     * @notice Get assessment details
     */
    function getAssessment(uint256 _assessmentId) external view returns (
        address user,
        uint256 selectedPaperId,
        uint256 timestamp,
        uint8 guidanceScore
    ) {
        CareerAssessment memory assessment = assessments[_assessmentId];
        require(assessment.user == msg.sender, "Not authorized");
        
        return (
            assessment.user,
            assessment.selectedPaperId,
            assessment.timestamp,
            assessment.guidanceScore
        );
    }

    /**
     * @notice Withdraw contract balance
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

    receive() external payable {}
}
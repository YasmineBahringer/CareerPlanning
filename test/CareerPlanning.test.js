const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CareerPlanningContract", function () {
  let careerPlanningContract;
  let owner;
  let user1;
  let user2;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    
    const CareerPlanningContract = await ethers.getContractFactory("CareerPlanningContract");
    careerPlanningContract = await CareerPlanningContract.deploy();
    await careerPlanningContract.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should deploy successfully", async function () {
      expect(await careerPlanningContract.getAddress()).to.be.properAddress;
    });

    it("Should have zero assessments initially", async function () {
      expect(await careerPlanningContract.getAssessmentCount()).to.equal(0);
    });
  });

  describe("Career Assessment Submission", function () {
    it("Should allow users to submit assessments with correct payment", async function () {
      const nonce = 12345; // Random nonce for privacy
      const tx = await careerPlanningContract.connect(user1).submitCareerAssessment(
        true,   // career goal
        false,  // skill level
        true,   // education priority
        nonce,  // nonce
        { value: ethers.parseEther("0.001") }
      );

      const receipt = await tx.wait();
      
      // Check that assessment count increased
      expect(await careerPlanningContract.getAssessmentCount()).to.equal(1);
      
      // Check that user has 1 assessment
      expect(await careerPlanningContract.getUserAssessmentCount(user1.address)).to.equal(1);

      // Check event emission
      expect(receipt.logs).to.have.lengthOf(1);
    });

    it("Should reject submissions with insufficient payment", async function () {
      await expect(
        careerPlanningContract.connect(user1).submitCareerAssessment(
          true, false, true, 12345,
          { value: ethers.parseEther("0.0005") }
        )
      ).to.be.revertedWith("Minimum fee required");
    });
  });

  describe("Assessment Management", function () {
    beforeEach(async function () {
      await careerPlanningContract.connect(user1).submitCareerAssessment(
        true, false, true, 12345,
        { value: ethers.parseEther("0.001") }
      );
    });

    it("Should allow users to request their assessment results", async function () {
      const tx = await careerPlanningContract.connect(user1).requestAssessmentResult(1);
      const receipt = await tx.wait();

      expect(await careerPlanningContract.isResultRequested(1)).to.be.true;
      expect(receipt.logs).to.have.lengthOf(1);
    });

    it("Should not allow non-owners to request others' results", async function () {
      await expect(
        careerPlanningContract.connect(user2).requestAssessmentResult(1)
      ).to.be.revertedWith("Not your assessment");
    });

    it("Should return correct user assessments", async function () {
      const assessments = await careerPlanningContract.getUserAssessments(user1.address);
      expect(assessments).to.have.lengthOf(1);
      expect(assessments[0]).to.equal(1);
    });
  });

  describe("Multiple Users", function () {
    it("Should handle multiple users correctly", async function () {
      // User1 submits 2 assessments
      await careerPlanningContract.connect(user1).submitCareerAssessment(
        true, false, true,
        { value: ethers.parseEther("0.001") }
      );
      await careerPlanningContract.connect(user1).submitCareerAssessment(
        false, true, false,
        { value: ethers.parseEther("0.001") }
      );

      // User2 submits 1 assessment
      await careerPlanningContract.connect(user2).submitCareerAssessment(
        true, true, true,
        { value: ethers.parseEther("0.001") }
      );

      expect(await careerPlanningContract.getAssessmentCount()).to.equal(3);
      expect(await careerPlanningContract.getUserAssessmentCount(user1.address)).to.equal(2);
      expect(await careerPlanningContract.getUserAssessmentCount(user2.address)).to.equal(1);
    });
  });
});
const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying CareerPlanningFHE...");
    
    const [deployer] = await ethers.getSigners();
    console.log("Deploying with account:", deployer.address);
    const balance = await deployer.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.utils.formatEther(balance), "ETH");

    const CareerPlanningFHE = await ethers.getContractFactory("CareerPlanningFHE");
    
    console.log("Deploying contract...");
    const contract = await CareerPlanningFHE.deploy();
    
    console.log("Waiting for deployment...");
    await contract.deployed();
    
    const contractAddress = contract.address;
    console.log("✅ CareerPlanningFHE deployed to:", contractAddress);
    
    // Test the contract
    console.log("Testing contract...");
    const assessmentCount = await contract.getAssessmentCount();
    console.log("Initial assessment count:", assessmentCount.toString());
    
    // Save deployment info
    const deploymentInfo = {
        contractAddress: contractAddress,
        deployer: deployer.address,
        network: "localhost",
        timestamp: new Date().toISOString(),
        contractName: "CareerPlanningFHE"
    };
    
    const fs = require('fs');
    fs.writeFileSync('./deployment-fhe.json', JSON.stringify(deploymentInfo, null, 2));
    console.log("📝 Deployment info saved to deployment-fhe.json");
    
    console.log("🎉 CareerPlanningFHE Deployment completed successfully!");
    console.log("Contract address:", contractAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Deployment failed:", error);
        process.exit(1);
    });
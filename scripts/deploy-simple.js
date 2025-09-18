const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying CareerPlanningSimple to Sepolia...");
    
    const [deployer] = await ethers.getSigners();
    console.log("Deploying with account:", deployer.address);
    const balance = await deployer.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.utils.formatEther(balance), "ETH");

    const CareerPlanningSimple = await ethers.getContractFactory("CareerPlanningSimple");
    
    console.log("Deploying contract...");
    const contract = await CareerPlanningSimple.deploy();
    
    console.log("Waiting for deployment...");
    await contract.deployed();
    
    const contractAddress = contract.address;
    console.log("✅ CareerPlanningSimple deployed to:", contractAddress);
    
    // Test the contract
    console.log("Testing contract...");
    const assessmentCount = await contract.getAssessmentCount();
    console.log("Initial assessment count:", assessmentCount.toString());
    
    // Save deployment info
    const deploymentInfo = {
        contractAddress: contractAddress,
        deployer: deployer.address,
        network: "sepolia",
        timestamp: new Date().toISOString(),
        contractName: "CareerPlanningSimple"
    };
    
    const fs = require('fs');
    fs.writeFileSync('./deployment-simple.json', JSON.stringify(deploymentInfo, null, 2));
    console.log("📝 Deployment info saved to deployment-simple.json");
    
    console.log("🎉 Deployment completed successfully!");
    console.log("Contract address:", contractAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Deployment failed:", error);
        process.exit(1);
    });
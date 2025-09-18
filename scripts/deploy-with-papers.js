const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying CareerPlanningWithPapers...");
    
    const [deployer] = await ethers.getSigners();
    console.log("Deploying with account:", deployer.address);
    const balance = await deployer.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.utils.formatEther(balance), "ETH");

    const CareerPlanningWithPapers = await ethers.getContractFactory("CareerPlanningWithPapers");
    
    console.log("Deploying contract...");
    const contract = await CareerPlanningWithPapers.deploy();
    
    console.log("Waiting for deployment...");
    await contract.deployed();
    
    const contractAddress = contract.address;
    console.log("✅ CareerPlanningWithPapers deployed to:", contractAddress);
    
    // Test the contract
    console.log("Testing contract...");
    const paperCount = await contract.getPaperCount();
    console.log("Initial paper count:", paperCount.toString());
    
    // Save deployment info
    const deploymentInfo = {
        contractAddress: contractAddress,
        deployer: deployer.address,
        network: "localhost",
        timestamp: new Date().toISOString(),
        contractName: "CareerPlanningWithPapers"
    };
    
    const fs = require('fs');
    fs.writeFileSync('./deployment-with-papers.json', JSON.stringify(deploymentInfo, null, 2));
    console.log("📝 Deployment info saved to deployment-with-papers.json");
    
    console.log("🎉 CareerPlanningWithPapers Deployment completed successfully!");
    console.log("Contract address:", contractAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Deployment failed:", error);
        process.exit(1);
    });
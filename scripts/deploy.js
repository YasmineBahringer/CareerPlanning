const hre = require("hardhat");

async function main() {
  console.log("Deploying CareerPlanningContract...");

  // 获取合约工厂
  const CareerPlanningContract = await hre.ethers.getContractFactory("CareerPlanningContract");
  
  // 部署合约
  const contract = await CareerPlanningContract.deploy();
  
  // 等待部署完成
  await contract.deployed();
  
  const contractAddress = contract.address;
  
  console.log("CareerPlanningContract deployed to:", contractAddress);
  
  // 验证部署
  console.log("Verifying deployment...");
  const assessmentCount = await contract.getAssessmentCount();
  console.log("Initial assessment count:", assessmentCount.toString());
  
  // 保存部署信息到文件
  const deploymentInfo = {
    contractAddress: contractAddress,
    network: hre.network.name,
    timestamp: new Date().toISOString()
  };
  
  const fs = require('fs');
  fs.writeFileSync('./deployment.json', JSON.stringify(deploymentInfo, null, 2));
  console.log("Deployment info saved to deployment.json");
  
  console.log("\n=== UPDATE FRONTEND ===");
  console.log("Replace CONTRACT_ADDRESS with:", contractAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

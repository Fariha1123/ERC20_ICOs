var FarihaToken = artifacts.require("./FarihaToken.sol");
module.exports = function(deployer){
    deployer.deploy(FarihaToken);
}
const ticketingSystem = artifacts.require("./ticketingSystem.sol");

module.exports = (deployer) => {
    deployer.deploy(ticketingSystem);
};
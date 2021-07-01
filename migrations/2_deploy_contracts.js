const USDT = artifacts.require("USDT.sol");
const VLC = artifacts.require("VLC.sol");

module.exports = function (deployer) {
  deployer.deploy(VLC);
  deployer.deploy(USDT);
};

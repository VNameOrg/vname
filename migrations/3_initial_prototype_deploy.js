var NickStorage = artifacts.require("./NickStorage.sol");
var CryptoNick = artifacts.require("./CryptoNick.sol");
var COALITE1Token = artifacts.require("./COALITE1Token.sol");

module.exports = function(deployer, network, accounts) {
  //deploy NickStorage to BlockChain
  deployer.deploy(NickStorage/*, {from: accounts[0]}*/)
  .then(function() {
    //deploy CryptoNick to BlockChain with reference to NickStorage address
    deployer.deploy(CryptoNick, NickStorage.address/*, {from: accounts[0]}*/)
    .then(function() {
      //add CryptoNick as owner of NickStorage
      NickStorage.deployed()
      .then(function(instance) {
        return instance.addOwner(CryptoNick.address, 9/*, {from: accounts[0]}*/);
      })
      .then(function() {
        CryptoNick.deployed()
        .then(function (instance) {
          instance.setTokenAddress(COALITE1Token.address/*, {from: accounts[0]}*/);
        });
      });
    });
  });
};

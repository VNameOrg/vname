var COALITE1Token = artifacts.require("./COALITE1Token.sol");

module.exports = function(deployer, network, accounts) {

  //deploy Coalite Token
  deployer.deploy(COALITE1Token, 'Coalite', '💠', 2, 10000/*, {from: accounts[0]}*/)
    .then(function() {

    });
};

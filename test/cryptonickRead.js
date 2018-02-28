var CryptoNick = artifacts.require("CryptoNick");

contract("CryptoNick", function(accounts) {

    it("should be able to read from NickStorage", function() {
        var crypto;
        CryptoNick.deployed()
        .then(function(instance) {
            crypto = instance;
            return crypto.getNickNameOf(accounts[3]);
        })
        .then(function(response) {
            console.log(response);
        });
    });
});
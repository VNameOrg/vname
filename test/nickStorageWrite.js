var NickStorage = artifacts.require("NickStorage");

contract("NickStorage", function(accounts){

    it("should be able to deploy several nicknames in an array", function() {
        var nick;
        NickStorage.deployed()
        .then(function(instance) {
            nick = instance;
            return nick.setUserAndPush(
                accounts[0],
                "0x06163636f756e742031a000000000000000000000000000000000000000000000",
                false, 
                {from: accounts[0]}
            )
        })
        .then(function() {
            return nick.setUserAndPush(
                accounts[1],
                "0x06163636f756e742032a000000000000000000000000000000000000000000000",
                false, 
                {from: accounts[0]}
            )
        })
        .then(function() {
            return nick.setUserAndPush(
                accounts[2],
                "0x06163636f756e742033a000000000000000000000000000000000000000000000",
                false, 
                {from: accounts[0]}
            )
        })
        .then(function() {
            return nick.setUserAndPush(
                accounts[3],
                "0x06163636f756e742034a000000000000000000000000000000000000000000000",
                false, 
                {from: accounts[0]}
            )
        })
        .then(function() {
            return nick.setUserAndPush(
                accounts[4],
                "0x06163636f756e742035a000000000000000000000000000000000000000000000",
                false, 
                {from: accounts[0]}
            )
        });
    });
});
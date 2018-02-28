var CryptoNick = artifacts.require("CryptoNick");
var COALITE1Token = artifacts.require("./COALITE1Token.sol");

contract('CryptoNick', function(accounts) {

    var nick_Boop = "0x426f6f7000000000000000000000000000000000000000000000000000000000";

    it("should be able to assign a nickname to a user", function() {
        var cryptoNick;

        CryptoNick.deployed()
        .then(function(instance) {
            cryptoNick = instance;
            return cryptoNick.getNextFreeID();
        })
        .then(function(response) { 
            //console.log(response);
            return cryptoNick.assignNickName(
                nick_Boop,
                response,
                {from: accounts[0]});
        })
        .then(function(response) {
            // console.log(response);
            return cryptoNick.getNickNameOf(accounts[0]);
        })
        .then(function(response) {
            response = response.toString().split(',');
            assert.equal(response[0], "Boop", "Response does not match expected Nickname");
        });
    });

    it("should be able to verify a nickname", function() {
        var cryptoNick;
        var token;

        COALITE1Token.deployed()
        .then(function(instance) {
            token = instance;
            CryptoNick.deployed()
            .then(function(instance2) {
                cryptoNick = instance2;
                //console.log(token);
                return token.transfer(CryptoNick.address, 100, {from: accounts[0]});
            })
            .then(function() {
                return cryptoNick.getNickNameOf(accounts[0]);
            })
            .then(function(response) {
                response = response.toString().split(',');
                assert.equal(response[1].trim(), "true", "Response does not return true on verified");
            });
        });
    });

    it("should be able to check if a nickname is verified", function() {
        var cryptoNick;
        CryptoNick.deployed()
        .then(function(instance) {
            cryptoNick = instance;
            return cryptoNick.nicknameIsVerified(
                nick_Boop);
        })
        .then(function(response) {
            
            assert.equal(response, "true", "Response says nickname is not verified");
        });
    });

    // it("should not allow verification if the nickname is already in use", function() {
    //     var cryptoNick;
    //     CryptoNick.deployed()
    //     .then(function(instance) {
    //         cryptoNick = instance;
    //         return 
    //     })
    // })
});
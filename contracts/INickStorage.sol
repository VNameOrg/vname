pragma solidity ^0.4.17;

import './Util/OwnerUtil.sol';

interface INickStorage {
    function getUser(address _user) public view returns (bytes2, bytes32, bytes32, bool);
    function getUserSimple(address _user) public view returns (bytes32);
    function getData(address _user, bytes32 _dat) public view returns (bytes32);
    function getArrayLength(bytes32 _nick) public view returns (uint);
    function getNick(bytes32 _nick, uint _id) public view returns (bytes2, bytes32, bytes32, bool);
    function setUser(address _user, bytes2 _id, bytes32 _nick, bool _verified) public;
    function verifyUser(address _user) public;
    function setUserAndPush(address _user, bytes2 _id, bytes32 _nick, bool _verified) public;
    function findOne(bytes32 _nick) public view returns (bool found);
    function find(bytes32 _nick) public view returns (bool found, uint256 res);
    function findHash(bytes32 _nick, address _user) public view returns (bool found, uint256 id);
    function findVerified(bytes32 _nick) external view returns (bool found, uint256 id);
    function removeNick(bytes32 _nick, uint16 id) public;
}
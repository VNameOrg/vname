pragma solidity ^0.4.17;

import './Util/OwnerUtil.sol';

contract NickStorage is OwnerUtil {

    struct User {
        bytes2 id;
        bytes32 addrHash;
        bytes32 nick; 
        bool verified;
        mapping(bytes32 => bytes32) data;
    }

    mapping(address => User) private users;
    mapping(bytes32 => User[]) private nicks;
    mapping(bytes32 => bool) private verified;

    function NickStorage() public {

        owners[msg.sender] = Permissions(true, 10);
    }

    function getUser(address _user) public view returns (bytes2, bytes32, bytes32, bool) {

        return (users[_user].id, users[_user].addrHash, users[_user].nick, users[_user].verified);
    }

    function getUserSimple(address _user) public view returns (bytes32) {

        return users[_user].nick;
    }

    function getData(address _user, bytes32 _dat) public view returns (bytes32) {

        return users[_user].data[_dat];
    }

    function getArrayLength(bytes32 _nick) public view returns (uint) {

        return nicks[_nick].length;
    }

    function getNick(bytes32 _nick, uint _id) public view returns (bytes2, bytes32, bytes32, bool) {

        return (nicks[_nick][_id].id, nicks[_nick][_id].addrHash, nicks[_nick][_id].nick, nicks[_nick][_id].verified);
    }

    /**
     * @dev Sets a User for a specified address
     * @param _user Address of user being assigned
     * @param _nick Nickname to give the User instsance
     * @param _verified Is this Nickname verified for said Address
     */
    function setUser(address _user, bytes2 _id, bytes32 _nick, bool _verified) onlyOwner public {

        users[_user] = User(_id, keccak256(_user), _nick, _verified);
    }

    function verifyUser(address _user) onlyOwner public {

        require(!users[_user].verified);

        User memory usr = users[_user];
        usr.verified = true;
        users[_user] = usr;

        bool found;
        uint256 id;

        (found, id) = findHash(usr.nick, _user);

        if (found) {

            nicks[usr.nick][id] = User(usr.id, keccak256(_user), usr.nick, true);
        }

    }

    /**
     * @dev Pushes a User instance to the storage array if it doesnt exist;
            Overwrites otherwise.
     * @param _addr Address of the User's owner
     * @param _nick Nickname given to the User instance
     * @param _verified Is this Nickname verified for said User
     */
    function setNick(address _addr, bytes2 _id, bytes32 _nick, bool _verified) onlyOwner public {

        uint16 id = uint16(_id);
        if (id+1 > nicks[_nick].length) {

            nicks[_nick].push(User(users[_addr].id, keccak256(_addr), _nick, _verified));
        } else {

            nicks[_nick][id] = User(users[_addr].id, keccak256(_addr), _nick, _verified);
        }
    }

    /**
     * @dev Composite function: Sets a User for specified address and Pushes User to storage array
     * @param _user Address of user being assigned
     * @param _nick Nickname to give the User instsance
     * @param _verified Is this Nickname verified for said Address
     */
    function setUserAndPush(address _user, bytes2 _id, bytes32 _nick, bool _verified) onlyOwner public {

        setUser(_user, _id, _nick, _verified);
        setNick(_user, _id, _nick, _verified);
    }

   
    /**
     * @dev Searches mapping for specified Nickname and returns if found
     * @param _nick Nickname to be searched
     * @return found If the specified Nickname was found
     */
    function findOne(bytes32 _nick) onlyOwner public view returns (bool found) {

        if (nicks[_nick].length > 0) {

            return true;
        }
    }

    /**
     * @dev Searches mapping for specified Nickname and returns if found and the amount
     * @param _nick Nickname to be searched
     * @return found If the specified Nickname was found
     * @return res The number of Users on this nickname
     */
    function find(bytes32 _nick) onlyOwner public view returns (bool found, uint256 res) {

        if (nicks[_nick].length > 0) {

            return (true, nicks[_nick].length);
        } else {
            
            return (false, 0);
        }
    }

    function findHash(bytes32 _nick, address _user) onlyOwner public view returns (bool found, uint256 id) {

        for (uint256 i = 0; i < nicks[_nick].length; i++) {
            
            if (nicks[_nick][i].addrHash == keccak256(_user)) {

                return (true, i);
            }

        }

        return (false, 0);
    }

    function findVerified(bytes32 _nick) onlyOwner external view returns (bool found, uint256 id) {

        for (uint256 i = 0; i < nicks[_nick].length; i++) {
            
            if (nicks[_nick][i].verified) {

                return (true, i);
            }
        }

        return (false, 0);
    }

    /**
     * @dev 'Removes' the specified ID from the storage array
     * @param id The ID of the instance to remove
     */
    function removeNick(bytes32 _nick, uint16 id) onlyOwner public {

        delete nicks[_nick][id];
    }
}
pragma solidity ^0.4.17;

import './Util/OwnerUtil.sol';

contract NickStorage is OwnerUtil {

    struct User {
        bytes32 ref;
        bytes2 id;
        bytes32 addrHash;
        bytes32 nick; 
        bool verified;
        bytes32[8] desc;
        mapping(bytes32 => bytes32) data;
    }

    struct UserInArray {
        bytes32 ref;
        bytes2 id;
        bytes32 addrHash;
        bytes32 nick; 
        bool verified;
    }

    mapping(address => User) private users;
    mapping(bytes32 => UserInArray[]) private nicks;
    mapping(bytes32 => uint) private count;
    mapping(bytes32 => bool) private verified;

    function NickStorage() public {

        owners[msg.sender] = Permissions(true, 10);
    }

    function getUser(address _user) public view returns (bytes32, bytes2, bytes32, bytes32, bool) {

        return (users[_user].ref, users[_user].id, users[_user].addrHash, users[_user].nick, users[_user].verified);
    }

    function getUserSimple(address _user) public view returns (bytes32) {

        return users[_user].nick;
    }

    function getDescription(address _user) public view returns (bytes32[8]) {
        return users[_user].desc;
    }

    function getData(address _user, bytes32 _dat) public view returns (bytes32) {

        return users[_user].data[_dat];
    }

    function getArrayLength(bytes32 _ref) public view returns (uint) {

        return count[_ref];
    }

    function getNick(bytes32 _ref, uint _id) public view returns (bytes2, bytes32, bytes32, bool) {

        return (nicks[_ref][_id].id, nicks[_ref][_id].addrHash, nicks[_ref][_id].nick, nicks[_ref][_id].verified);
    }

    /**
     * @dev Sets a User for a specified address
     * @param _ref internal case-insensitive nickname reference
     * @param _user Address of user being assigned
     * @param _nick Nickname to give the User instsance
     * @param _verified Is this Nickname verified for said Address
     */
    function setUser(bytes32 _ref, address _user, bytes2 _id, bytes32 _nick, bool _verified) onlyOwner public {
        
        bytes32[8] memory _desc;
        users[_user] = User(_ref, _id, keccak256(_user), _nick, _verified, _desc);
    }

    function verifyUser(address _user) onlyOwner public {

        require(!users[_user].verified);

        User memory usr = users[_user];
        usr.verified = true;
        users[_user] = usr;

        bool found;
        uint256 id;

        (found, id) = findHash(usr.nick, _user);

        require(found);

            nicks[usr.nick][id] = UserInArray(usr.ref, usr.id, keccak256(_user), usr.nick, true);
    }

    /**
     * @dev Pushes a User instance to the storage array if it doesnt exist;
            Overwrites otherwise.
     * @param _ref internal case-insensitive nickname reference
     * @param _addr Address of the User's owner
     * @param _nick Nickname given to the User instance
     * @param _verified Is this Nickname verified for said User
     */
    function setNick(bytes32 _ref, address _addr, bytes2 _id, bytes32 _nick, bool _verified) onlyOwner public {

        uint16 id = uint16(_id);
        if (id+1 > nicks[_nick].length) {

            nicks[_ref].push(UserInArray(_ref, users[_addr].id, keccak256(_addr), _nick, _verified));
        } else {

            nicks[_ref][id] = UserInArray(_ref, users[_addr].id, keccak256(_addr), _nick, _verified);
        }
    }

    function setCount(bytes32 _ref, uint _count) onlyOwner public {
        count[_ref] = _count;
    }

    /**
     * @dev Composite function: Sets a User for specified address and Pushes User to storage array
     * @param _ref internal case-insensitive nickname reference
     * @param _user Address of user being assigned
     * @param _nick Nickname to give the User instsance
     * @param _verified Is this Nickname verified for said Address
     */
    function setUserAndPush(bytes32 _ref, address _user, bytes2 _id, bytes32 _nick, bool _verified) onlyOwner public {

        setUser(_ref, _user, _id, _nick, _verified);
        setNick(_ref, _user, _id, _nick, _verified);
        setCount(_ref, count[_ref] + 1);
    }

   
    /**
     * @dev Searches mapping for specified Nickname and returns if found
     * @param _ref internal case-insensitive nickname reference
     * @return found If the specified Nickname was found
     */
    function findOne(bytes32 _ref) onlyOwner public view returns (bool found) {

        if (nicks[_ref].length > 0) {

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
    function removeNick(bytes32 _ref, uint16 id) onlyOwner public {

        count[_ref] = count[_ref] - 1;
        delete nicks[_ref][id];
    }
}
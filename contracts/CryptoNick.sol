pragma solidity ^0.4.17;

import './NickStorage.sol';
//import '../Util/OwnerUtil.sol';
import './COALITE/COALITE1Receiver.sol';

contract CryptoNick is COALITE1Receiver {

    NickStorage nickStorage;

    event AssignUser(address indexed user, bool result);

    function CryptoNick(address _store) public {

        nickStorage = NickStorage(_store);

        owners[msg.sender] = Permissions(true, 10);
    }

    function _tokenReceivedInternal(address _token, address _sender, uint _value, bytes _data) internal returns (bool) {

        if(_value == 100) {

            return verifyNickname(_sender);
        } else {

            return false;
        }
    }

    /**
     * @dev Get the NickName of the address and if it's verified
     * @param _user Address to be checked
     */
    function getNicknameOf(address _user) public view returns (string, bytes2, bool) {
        var (, id, , byt, ver ) = nickStorage.getUser(_user);
        
        string memory str = bytes32ToString(byt);
        
        return(str, id, ver);
    }
    
    function bytes32ToString(bytes32 x) pure internal returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function bytes32ArrayToString (bytes32[] data) pure internal returns (string) {
        bytes memory bytesString = new bytes(data.length * 32);
        uint urlLength;
        for (uint i=0; i<data.length; i++) {
            for (uint j=0; j<32; j++) {
                byte char = byte(bytes32(uint(data[i]) * 2 ** (8 * j)));
                if (char != 0) {
                    bytesString[urlLength] = char;
                    urlLength += 1;
                }
            }
        }
        bytes memory bytesStringTrimmed = new bytes(urlLength);
        for (i=0; i<urlLength; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }
        return string(bytesStringTrimmed);
    }

    /**
     * @dev cheks that a given string as bytes32 is valid and returns true if so,
     * the length of the string, and a parsed bytes32
     * 
     * @param str string to validate as bytes32
     * 
     * @return bool if the string is valid
     * @return uint8 length of string
     * @return bytes32 lower-cased version of str
     */
    function nickValidate(bytes32 str) public pure returns (bool, uint8, bytes32) {
        
        uint8 len = 0;

        for (uint8 i = 0; i < 32; i++) {
            
            byte char = byte(str << 8 * i);
            if (char != 0) {                                            //if char is not null
                if (char >= 0x41 && char <= 0x5a) {                         //if char is an upper-case ASCII character
                    bytes32 sum = bytes32(0x20) << 8 * (31 - i);
                    assembly{ str := add(str, sum) }
                } else {
                    if (char >= 0x61 && char <= 0x7a) {                     //if char is a lower-case ASCII character
                        
                    } else {
                        if (char >= 0x30 && char <= 0x39) {                 //if char is an ASCII number character
                            
                        } else {
                            if (char == 0x20) {                             //if char is an ASCII space character
                                if (i == 0) {
                                    str = str << 8;
                                } else {    
                                    bytes32 other = str >> 8 * (32 - i);
                                    other = other << 8 * (32 - i);
                                    str = str << 8 * (1 + i);
                                    str = str >> 8 * i;
                                    assembly{ str := add(str, other) }
                                }
                                --i;
                                --len;
                            } else {                                        //if char is a symbol character
                                return (false, len, 0x0);
                            }
                        }
                    }
                }
                ++len;
            } else {                                                       //if char is null
                str = str >> 8 * (32 - len);
                str = str << 8 * (32 - len);
                return (true, len, str);
            }
        }
        return (true, len, str);
    }

    /**
     * @dev Assign a Nickname to your Address
     * @param _nick Nickname to be assigned
     */
    function assignUser(bytes32 _nick, bytes2 _id) public returns (bool) {

        var (_refOld, _idOld, , nickOld, _valid) = nickStorage.getUser(msg.sender);
        
        //cant be the same nickname
        require(_nick != nickOld);

        bool n_valid;
        uint8 n_length;
        bytes32 n_parsed;

        (n_valid, n_length, n_parsed) = nickValidate(_nick);

        require(n_length >= 5 && n_length <= 32);

        if (uint16(_id) < nickStorage.getArrayLength(n_parsed)) {

            var ( , hash, , ) = nickStorage.getNick(n_parsed, uint16(_id));
        } else {
            hash = 0;
            _id = bytes2(nickStorage.getArrayLength(n_parsed));
        }

        //user doesnt have nickname
        if (nickOld == 0) {

            if (uint16(_id) >= nickStorage.getArrayLength(n_parsed)) {

                nickStorage.setUserAndPush(n_parsed, msg.sender, _id, _nick, false);
                AssignUser(msg.sender, true);
                return true;
            } else {

                if (hash == 0 || keccak256(msg.sender) == hash) {

                    nickStorage.setUserAndPush(n_parsed, msg.sender, _id, _nick, false);
                    AssignUser(msg.sender, true);
                    return true;
                } else {
                    AssignUser(msg.sender, false);
                    return false;
                }
            }

        // has a different nickname
        } else {

            if (_refOld == n_parsed) {                  //if internal reference is the same
                nickStorage.setUser(n_parsed, msg.sender, _idOld, _nick, _valid);
                nickStorage.setNick(n_parsed, msg.sender, _idOld, _nick, _valid);
            } else {                                    //if internal reference is different
                if (uint16(_id) >= nickStorage.getArrayLength(_nick)) {

                    nickStorage.removeNick(_refOld, uint16(_idOld));
                    nickStorage.setUserAndPush(n_parsed, msg.sender, _id, _nick, false);
                    return true;
                } else {

                    if (hash == 0) {

                        nickStorage.removeNick(nickOld, uint16(_idOld));
                        nickStorage.setUserAndPush(n_parsed, msg.sender, _id, _nick, false);
                        AssignUser(msg.sender, true);
                        return true;
                    } else {
                        AssignUser(msg.sender, false);
                        return false;
                    }
                } 
            }
        }
        AssignUser(msg.sender, false);
        return false;
    }

    function getNextFreeID(bytes32 _nick) public view returns (bytes2) {

        bool n_valid;
        uint8 n_length;
        bytes32 n_parsed;

        (n_valid, n_length, n_parsed) = nickValidate(_nick);

        uint len = nickStorage.getArrayLength(n_parsed);

        uint16 i;
        for (i = 0; i < len; ++i) {
            
            var ( , hash, , ) = nickStorage.getNick(n_parsed, i);

            if (hash == 0) {

                return bytes2(i);
            }
        }

        return bytes2(i);
    }

    function nicknameIsVerified(bytes32 _nick) public view returns (bool) {

        bool n_valid;
        uint8 n_length;
        bytes32 n_parsed;

        (n_valid, n_length, n_parsed) = nickValidate(_nick);
        
        var (found,) = nickStorage.findVerified(n_parsed);
        return found;
    }

    /**
     * @dev Gets how many addresses are using that nickname
     */
    function nicknameCount(bytes32 _nick) public view returns (uint) {

        bool n_valid;
        uint8 n_length;
        bytes32 n_parsed;

        (n_valid, n_length, n_parsed) = nickValidate(_nick);

        uint count = nickStorage.getArrayLength(n_parsed);
        return count;
    }

    /**
     * @dev Verify your Nickname. Payable: value must be above 1200000000000000 wei
     */
    function verifyNickname(address _usr) internal returns (bool) {

        bytes32 nick = nickStorage.getUserSimple(_usr);
        var (found,) = nickStorage.findVerified(nick);
        require(!found);

        nickStorage.verifyUser(_usr);
        return true;
    }

    function idToStr(bytes2 _byt) public pure returns (bytes4) {
        
        //split bytes2 into two bytes
        byte b1 = byte(_byt);
        byte b2 = byte(_byt << 8);
        //allocate memory for bitwise operations
        byte m1; byte m2;
        
        //allocate memory for result bytes
         byte b1a; byte b1b; byte b2a; byte b2b;
        
        //first byte 
        
        ///get first 4 bits
        m1 = b1 >> 4;
        m2 = b1 << 4;
        m2 = m2 >> 4;
        
        if (m1 < 0x0a) {
            b1a = assemblyAdd(m1, 0x30);
        } else {
            b1a = assemblyAdd(assemblySub(m1, 0x09), 0x60);
        }
        
        if (m2 < 0x0a) {
            b1b = assemblyAdd(m2, 0x30);
        } else {
            b1b = assemblyAdd(assemblySub(m2, 0x09), 0x60);
        }
        
        
        //second byte 
        
        ///get first 4 bits
        m1 = b2 >> 4;
        m2 = b2 << 4;
        m2 = m2 >> 4;
        
        if(m1 < 0x0a) {
            b2a = assemblyAdd(m1, 0x30);
        } else {
            b2a = assemblyAdd(assemblySub(m1, 0x09), 0x60);
        }
        
        if(m2 < 0x0a) {
            b2b = assemblyAdd(m2, 0x30);
        } else {
            b2b = assemblyAdd(assemblySub(m2, 0x09), 0x60);
        }
        
        uint32 Ub1a = uint32(b1a);
        uint32 Ub1b = uint32(b1b);
        uint32 Ub2a = uint32(b2a);
        uint32 Ub2b = uint32(b2b);
        
        //pass bytes into bytes4 for return
        Ub1a = Ub1a << 24;
        Ub1b = Ub1b << 16;
        Ub2a = Ub2a << 8;
        Ub2b = Ub2b << 0;
        
        uint32 res;
        
        res = Ub1a + Ub1b + Ub2a + Ub2b;
        
        return bytes4(res);
    }
    
    function assemblyAdd(byte a, byte b) public pure returns (byte) {
        
        byte c;
        
        assembly{
            c := add(a, b)
        }
        
        return c;
    }
    
    function assemblySub(byte a, byte b) public pure returns (byte) {
        
        byte c;
        
        assembly{
            c := sub(a, b)
        }
        
        return c;
    }
    
    function assemblyLast(byte b) public pure returns (byte) {
        byte r;
        
        assembly {
            r := and(0x0f, b)
        }
        
        return r;
    }
}
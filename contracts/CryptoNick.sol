pragma solidity ^0.4.17;

import './NickStorage.sol';
//import '../Util/OwnerUtil.sol';
import './COALITE/COALITE1Receiver.sol';

contract CryptoNick is COALITE1Receiver {

    NickStorage nickStorage;

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
    function getNickNameOf(address _user) public view returns (string, bool) {
        var (, , byt, ver ) = nickStorage.getUser(_user);
        
        string memory str = bytes32ToString(byt);
        
        return(str, ver);
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

    /**
     * @dev Assign a Nickname to your Address
     * @param _nick Nickname to be assigned
     */
    function assignUser(bytes32 _nick, bytes2 _id) public returns (bool) {

        uint16 id = uint16(_id);
        var (_idOld, , nickOld, ) = nickStorage.getUser(msg.sender);
        uint16 idOld = uint16(_idOld);

        //cant be the same nickname
        require(_nick != nickOld);

        //user doesnt have nickname
        if (nickOld == 0) {

            if (id >= nickStorage.getArrayLength(_nick)) {

                nickStorage.setUserAndPush(msg.sender, _id, _nick, false);
                return true;
            } else {

                var ( , hash, , ) = nickStorage.getNick(_nick, id);

                if (hash == 0 || keccak256(msg.sender) == hash) {

                    nickStorage.setUserAndPush(msg.sender, _id, _nick, false);
                    return true;
                } else {
                    return false;
                }
            }

        // has a different nickname
        } else {

            if (id >= nickStorage.getArrayLength(_nick)) {

                nickStorage.removeNick(nickOld, idOld);
                nickStorage.setUserAndPush(msg.sender, _id, _nick, false);
                return true;
            } else {
                
                var ( , hash1, , ) = nickStorage.getNick(_nick, id);

                if (hash1 == 0) {

                    nickStorage.removeNick(nickOld, idOld);
                    nickStorage.setUserAndPush(msg.sender, _id, _nick, false);
                    return true;
                } else {
                    return false;
                }
            }
        }
        return false;
    }

    function getNextFreeID(bytes32 _nick) public view returns (bytes2) {

        uint len = nickStorage.getArrayLength(_nick);

        uint16 i;
        for (i = 0; i < len; ++i) {
            
            var ( , hash, , ) = nickStorage.getNick(_nick, i);

            if (hash == 0) {

                return bytes2(i);
            }
        }

        return bytes2(i + 1);
    }

    function nicknameIsVerified(bytes32 _nick) public view returns (bool) {
        
        var (found,) = nickStorage.findVerified(_nick);
        return found;
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
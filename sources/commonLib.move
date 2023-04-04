module basics::commonLib {
    use std::vector;
    // friend basics::communityLib;
    use sui::object::{Self, ID, UID};


    /* errors */

    const E_INVALIT_IPFSHASH: u64 = 30;

    struct IpfsHash has store, copy, drop {
      hash: vector<u8>,
      hash2: vector<u8> // Not currently used and added for the future compatibility
    }


    public fun isEmptyIpfs(hash: vector<u8>): bool {
        hash == vector::empty<u8>()
    }

    public fun getIpfsDoc(hash: vector<u8>, hash2: vector<u8>): IpfsHash {
        IpfsHash { hash: hash, hash2: hash2 }
    }

    public fun getIpfsHash(ipfsHash: IpfsHash): vector<u8> {
        ipfsHash.hash
    }

    public fun getTimestamp(): u64 {    // TODO: add
        0
    }


    public fun getPeriod(): u64 {    // TODO: add
        0
    }

    public fun getErrorInvalidIpfsHash(): u64 {
        E_INVALIT_IPFSHASH
    }

    public fun getItemId(uid: &UID): ID  {
        object::uid_to_inner(uid)
    }

    // public fun setIpfsDoc(hash: vector<u8>, hash2: vector<u8>, ipfsHash2: vector<u8>): IpfsHash {   // need? we have getIpfsDoc()
    //     IpfsHash { hash: hash, hash2: hash2  }
    // }
}
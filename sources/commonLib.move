module basics::commonLib {
    use std::vector;
    // friend basics::communityLib;


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

    // public fun setIpfsDoc(hash: vector<u8>, hash2: vector<u8>, ipfsHash2: vector<u8>): IpfsHash {   // need? we have getIpfsDoc()
    //     IpfsHash { hash: hash, hash2: hash2  }
    // }
}
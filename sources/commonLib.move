module basics::commonLib {
    use std::vector;
    use sui::object::{Self, ID};
    use sui::clock::{Self, Clock};


    // ====== Errors ======

    const E_INVALIT_IPFSHASH: u64 = 30;

    // ====== Constant ======

    const BOT_BYTES_ADDRESS: vector<u8> = vector[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];

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

    public fun getTimestamp(time: &Clock): u64 {
        clock::timestamp_ms(time)
    }

    public fun getErrorInvalidIpfsHash(): u64 {
        E_INVALIT_IPFSHASH
    }

    public fun getZeroId(): ID {
        object::id_from_address(@0x0)
    }

    public fun get_bot_id(): ID {
        object::id_from_bytes(BOT_BYTES_ADDRESS)
    }

    public fun compose_messenger_sender_property(messengerType: u8, handle: vector<u8>): vector<u8> {
        let authorMetaData = vector[messengerType];
        vector::append<u8>(&mut authorMetaData, handle);
        authorMetaData
    }
}
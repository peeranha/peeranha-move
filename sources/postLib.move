module basics::postLib {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use std::debug;
    use basics::communityLib;
    use basics::commonLib;

    /// A shared user.
    struct PostCollection has key {
        id: UID,
        posts: vector<Post>,
        postCount: u128
    }

    struct Post has store, drop {
        // PostType postType;
        ipfsDoc: commonLib::IpfsHash,
        postTime: u64,
        author: address,
        rating: u64,
        communityId: u64,

        officialReply: u64,
        bestReply: u64,
        deletedReplyCount: u8,  // uint16
        isDeleted: bool,

        tags: vector<u64>,
        replies: vector<Reply>,
        comments: vector<Comment>,
        properties: vector<u8>,

        historyVotes: vector<u128>,                 // to u8?
        votedUsers: vector<address>
    }

    struct Reply has store, drop {
        ipfsDoc: commonLib::IpfsHash,
        postTime: u64,
        author: address,
        rating: u64,
        parentReplyId: u64,         //uint16?
        
        isFirstReply: bool,
        isQuickReply: bool,
        isDeleted: bool,

        comments: vector<Comment>,
        properties: vector<u8>,
        historyVotes: vector<u128>,                 // to u8?
        votedUsers: vector<address>
    }

    struct Comment has store, drop {
        ipfsDoc: commonLib::IpfsHash,
        postTime: u64,
        author: address,
        rating: u64,

        isDeleted: bool,

        properties: vector<u8>,
        historyVotes: vector<u128>,                 // to u8?
        votedUsers: vector<address>
    }
   
    public entry fun initPostCollection(ctx: &mut TxContext) {
        transfer::share_object(PostCollection {
            id: object::new(ctx),
            posts: vector::empty<Post>(),
            postCount: 0,
        })
    }

    public entry fun createPost(
        postCollection: &mut PostCollection,
        communityCollection: &mut communityLib::CommunityCollection,
        userAddr: address,
        communityId: u64,
        ipfsHash: vector<u8>, 
        /*PostType postType,*/
        tags: vector<u64>
    ) {
        communityLib::onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        communityLib::checkTags(communityCollection, communityId, tags);
        //check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);

        vector::push_back(&mut postCollection.posts, Post {
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            postTime: 0,            //get time
            author: userAddr,                           // get time
            rating: 0,
            communityId: communityId,
            officialReply: 0,
            bestReply: 0,
            deletedReplyCount: 0,
            isDeleted: false,
            tags: tags,
            replies: vector::empty<Reply>(),
            comments: vector::empty<Comment>(),
            properties: vector::empty<u8>(),
            historyVotes: vector::empty<u128>(),
            votedUsers: vector::empty<address>(),
        });
        
        if (true) {       //postType != PostType.Documentation
            assert!(vector::length(&mut tags) > 0, 26);
            let postId = vector::length(&mut postCollection.posts) - 1;
            let post = getMutablePost(postCollection, postId);
            post.tags = tags;
        };

        // emit PostCreated(userAddr, communityId, self.postCount);
    }

    public entry fun createReply(
        postCollection: &mut PostCollection,
        userAddr: address,
        postId: u64,
        parentReplyId: u64,
        ipfsHash: vector<u8>,
        isOfficialReply: bool
    ) {
        let post = getMutablePost(postCollection, postId);
        // require(postContainer.info.postType != PostType.Tutorial && postContainer.info.postType != PostType.Documentation, 
    //         "You can not publish replies in tutorial or Documentation.");
    // require(
    //         parentReplyId == 0 || 
    //         (postContainer.info.postType != PostType.ExpertPost && postContainer.info.postType != PostType.CommonPost), 
    //         "User is forbidden to reply on reply for Expert and Common type of posts"
    //     );

        //check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);


        if (true) {     //postContainer.info.postType == PostType.ExpertPost || postContainer.info.postType == PostType.CommonPost
            let countReplies = vector::length(&mut post.replies);

            let replyId = 0;
            while (replyId < countReplies) {
                let replyContainer = getReply(post, replyId);
                assert!(userAddr != replyContainer.author || replyContainer.isDeleted, 41);
            };
        };

        // if (parentReplyId == 0) {
    //         if (isOfficialReply) {
    //             postContainer.info.officialReply = postContainer.info.replyCount;
    //         }

    //         if (postContainer.info.postType != PostType.Tutorial && postContainer.info.author != userAddr) {
    //             if (postContainer.info.replyCount - postContainer.info.deletedReplyCount == 1) {    // unit test
    //                 replyContainer.info.isFirstReply = true;
    //                 self.peeranhaUser.updateUserRating(userAddr, VoteLib.getUserRatingChangeForReplyAction(postContainer.info.postType, VoteLib.ResourceAction.FirstReply), postContainer.info.communityId);
    //             }
    //             if (timestamp - postContainer.info.postTime < CommonLib.QUICK_REPLY_TIME_SECONDS) {
    //                 replyContainer.info.isQuickReply = true;
    //                 self.peeranhaUser.updateUserRating(userAddr, VoteLib.getUserRatingChangeForReplyAction(postContainer.info.postType, VoteLib.ResourceAction.QuickReply), postContainer.info.communityId);
    //             }
    //         }
    //     } else {
    //       getReplyContainerSafe(postContainer, parentReplyId);
    //       replyContainer.info.parentReplyId = parentReplyId;  
    //     }

        vector::push_back(&mut post.replies, Reply {
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            postTime: 0,            //get time
            author: userAddr,                           // get time
            rating: 0,
            parentReplyId: parentReplyId,
            
            isFirstReply: false,
            isQuickReply: false,
            isDeleted: false,

            comments: vector::empty<Comment>(),
            properties: vector::empty<u8>(),
            historyVotes: vector::empty<u128>(),
            votedUsers: vector::empty<address>(),
        });

        // emit ReplyCreated(userAddr, postId, parentReplyId, postContainer.info.replyCount);
    }

    public entry fun createComment(
        postCollection: &mut PostCollection,
        userAddr: address,
        postId: u64,
        parentReplyId: u64,
        ipfsHash: vector<u8>, 
    ) {
        let post = getMutablePost(postCollection, postId);
        // require(postContainer.info.postType != PostType.Documentation, "You can not publish comments in Documentation.");
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);
        
        // Comment storage comment;
        // uint8 commentId;            // struct? gas
        // address author;

        // if (parentReplyId == 0) {
        //     commentId = ++postContainer.info.commentCount;
        //     comment = postContainer.comments[commentId].info;
        //     author = postContainer.info.author;
        // } else {
        //     ReplyContainer storage replyContainer = getReplyContainerSafe(postContainer, parentReplyId);
        //     commentId = ++replyContainer.info.commentCount;
        //     comment = replyContainer.comments[commentId].info;
        //     if (postContainer.info.author == userAddr)
        //         author = userAddr;
        //     else
        //         author = replyContainer.info.author;
        // }

        //check role

        if (parentReplyId == 0) {
            vector::push_back(&mut post.comments, Comment {
                ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
                postTime: 0,            //get time
                author: userAddr,                           // get time
                rating: 0,
                isDeleted: false,

                properties: vector::empty<u8>(),
                historyVotes: vector::empty<u128>(),
                votedUsers: vector::empty<address>(),
            });
        } else {
            let reply = getMutableReply(post, parentReplyId);
            vector::push_back(&mut reply.comments, Comment {
                ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
                postTime: 0,            //get time
                author: userAddr,                           // get time
                rating: 0,
                isDeleted: false,

                properties: vector::empty<u8>(),
                historyVotes: vector::empty<u128>(),
                votedUsers: vector::empty<address>(),
            });
        }
        // emit CommentCreated(userAddr, postId, parentReplyId, commentId);
    }


    public fun getMutablePost(postCollection: &mut PostCollection, postId: u64): &mut Post {
        let post = vector::borrow_mut(&mut postCollection.posts, postId);
        post
    }

    public fun getPost(postCollection: &mut PostCollection, postId: u64): &Post {
        let post = vector::borrow(&mut postCollection.posts, postId);
        post
    }

    public fun getReply(post: &mut Post, replyId: u64): &Reply {
        let reply = vector::borrow(&mut post.replies, replyId);
        reply
    }

    public fun getMutableReply(post: &mut Post, replyId: u64): &mut Reply {
        let reply = vector::borrow_mut(&mut post.replies, replyId);
        reply
    }

}

// #[test_only]
// module basics::communityLib_test {
//     use sui::test_scenario;
//     use basics::userCollection;

    
// }

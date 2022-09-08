module basics::postLib {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use basics::communityLib;
    use basics::commonLib;

    struct PostCollection has key {
        id: UID,
        posts: vector<Post>,
        postCount: u128
    }

    struct Post has store, drop {
        // TODO: add PostType postType;
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
        parentReplyId: u64,
        
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
        /* // TODO: add PostType postType,*/
        tags: vector<u64>
    ) {
        communityLib::onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        communityLib::checkTags(communityCollection, communityId, tags);
        // TODO: add check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);

        vector::push_back(&mut postCollection.posts, Post {
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            postTime: 0,            // TODO: add get time
            author: userAddr,
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
        
        if (true) {       // TODO: add postType != PostType.Documentation
            assert!(vector::length(&mut tags) > 0, 26);
            let postId = vector::length(&mut postCollection.posts) - 1;
            let post = getMutablePost(postCollection, postId);
            post.tags = tags;
        };

        // TODO: add emit PostCreated(userAddr, communityId, self.postCount);
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
        // TODO: add
        // require(postContainer.info.postType != PostType.Tutorial && postContainer.info.postType != PostType.Documentation, 
    //         "You can not publish replies in tutorial or Documentation.");
    // require(
    //         parentReplyId == 0 || 
    //         (postContainer.info.postType != PostType.ExpertPost && postContainer.info.postType != PostType.CommonPost), 
    //         "User is forbidden to reply on reply for Expert and Common type of posts"
    //     );

        // TODO: add check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);


        if (true) {     // TODO: add postContainer.info.postType == PostType.ExpertPost || postContainer.info.postType == PostType.CommonPost
            let countReplies = vector::length(&post.replies);

            let replyId = 0;
            while (replyId < countReplies) {
                let replyContainer = getReply(post, replyId);
                assert!(userAddr != replyContainer.author || replyContainer.isDeleted, 41);
            };
        };

        // TODO: add
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
            postTime: 0,            // TODO: add get time
            author: userAddr,
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

        // TODO: add emit ReplyCreated(userAddr, postId, parentReplyId, postContainer.info.replyCount);
    }

    public entry fun createComment(
        postCollection: &mut PostCollection,
        userAddr: address,
        postId: u64,
        parentReplyId: u64,
        ipfsHash: vector<u8>, 
    ) {
        let post = getMutablePost(postCollection, postId);
        // TODO: add require(postContainer.info.postType != PostType.Documentation, "You can not publish comments in Documentation.");
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);
        
        // TODO: add
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

        // TODO: add check role

        if (parentReplyId == 0) {
            vector::push_back(&mut post.comments, Comment {
                ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
                postTime: 0,            // TODO: add get time
                author: userAddr,
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
                postTime: 0,            // TODO: add get time
                author: userAddr,
                rating: 0,
                isDeleted: false,

                properties: vector::empty<u8>(),
                historyVotes: vector::empty<u128>(),
                votedUsers: vector::empty<address>(),
            });
        }
        // TODO: add emit CommentCreated(userAddr, postId, parentReplyId, commentId);
    }

    public entry fun editPost(
        postCollection: &mut PostCollection,
        communityCollection: &mut communityLib::CommunityCollection,
        userAddr: address,
        postId: u64,
        ipfsHash: vector<u8>, 
        tags: vector<u64>
    ) {
        let post = getMutablePost(postCollection, postId);
        communityLib::checkTags(communityCollection, post.communityId, tags);

        // TODO: add check role
        
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);
        assert!(userAddr == post.author /* // TODO: add || postContainer.info.postType == PostType.Documentation*/, 42);

        if(!commonLib::isEmptyIpfs(ipfsHash) && commonLib::getIpfsHash(post.ipfsDoc) != ipfsHash)
            post.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
        if (vector::length(&tags) > 0)
            post.tags = tags;

        // TODO: add emit PostEdited(userAddr, postId);
    }

    public entry fun editReply(
        postCollection: &mut PostCollection,
        userAddr: address,
        postId: u64,
        replyId: u64,
        ipfsHash: vector<u8>, 
        isOfficialReply: bool
    ) {
        let post = getMutablePost(postCollection, postId);
        let reply = getMutableReply(post, replyId);

        // TODO: add check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);
        assert!(userAddr == reply.author, 43);

        if (commonLib::getIpfsHash(reply.ipfsDoc) != ipfsHash)
            reply.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        if (isOfficialReply) {
            post.officialReply = replyId;
        } else if (post.officialReply == replyId)
            post.officialReply = 0;

        // TODO: add emit ReplyEdited(userAddr, postId, replyId);
    }

    public entry fun editComment(
        postCollection: &mut PostCollection,
        userAddr: address,
        postId: u64,
        parentReplyId: u64,
        commentId: u64,
        ipfsHash: vector<u8>, 
    ) {
        let post = getMutablePost(postCollection, postId);
        let comment = getMutableComment (post, parentReplyId, commentId);

        // TODO: add check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);
        assert!(userAddr == comment.author, 44);

        if (commonLib::getIpfsHash(comment.ipfsDoc) != ipfsHash)
            comment.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        // TODO: add emit CommentEdited(userAddr, postId, parentReplyId, commentId);
    }


    public fun getMutablePost(postCollection: &mut PostCollection, postId: u64): &mut Post {
        vector::borrow_mut(&mut postCollection.posts, postId)
    }

    public fun getPost(postCollection: &mut PostCollection, postId: u64): &Post {
        vector::borrow(&mut postCollection.posts, postId)
    }

    public fun getReply(post: &mut Post, replyId: u64): &Reply {
        vector::borrow(&mut post.replies, replyId)
    }

    public fun getMutableReply(post: &mut Post, replyId: u64): &mut Reply {
        vector::borrow_mut(&mut post.replies, replyId)
    }

    public fun getMutableComment (post: &mut Post, parentReplyId: u64, commentId: u64): &mut Comment {
        if (parentReplyId == 0) {
            vector::borrow_mut(&mut post.comments, commentId)
        } else {
            let reply = getMutableReply(post, parentReplyId);
            vector::borrow_mut(&mut reply.comments, commentId)
        }
        // require(!CommonLib.isEmptyIpfs(commentContainer.info.ipfsDoc.hash), "Comment_not_exist.");

    }

    // function getCommentContainerSafe(
    //     PostContainer storage postContainer,
    //     uint16 parentReplyId,
    //     uint8 commentId
    // ) public view returns (CommentContainer storage) {
    //     CommentContainer storage commentContainer = getCommentContainer(postContainer, parentReplyId, commentId);

    //     require(!commentContainer.info.isDeleted, "Comment_deleted.");
    //     return commentContainer;
    // }

    public entry fun set_value(ctx: &mut TxContext) {       // do something with tx_context
        assert!(tx_context::sender(ctx) == tx_context::sender(ctx), 0);
    }
}

// #[test_only]
// module basics::communityLib_test {
//     use sui::test_scenario;
//     use basics::userCollection;

    
// }

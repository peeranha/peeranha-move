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
        isOfficialReply: bool      // TODO: add
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

        if (parentReplyId == 0) {
            if (isOfficialReply) {
                post.officialReply = vector::length(&mut post.replies);
            };

            // TODO: add
            // if (postContainer.info.postType != PostType.Tutorial && postContainer.info.author != userAddr) {
            //     if (postContainer.info.replyCount - postContainer.info.deletedReplyCount == 1) {    // unit test
            //         replyContainer.info.isFirstReply = true;
            //         self.peeranhaUser.updateUserRating(userAddr, VoteLib.getUserRatingChangeForReplyAction(postContainer.info.postType, VoteLib.ResourceAction.FirstReply), postContainer.info.communityId);
            //     }
            //     if (timestamp - postContainer.info.postTime < CommonLib.QUICK_REPLY_TIME_SECONDS) {
            //         replyContainer.info.isQuickReply = true;
            //         self.peeranhaUser.updateUserRating(userAddr, VoteLib.getUserRatingChangeForReplyAction(postContainer.info.postType, VoteLib.ResourceAction.QuickReply), postContainer.info.communityId);
            //     }
            // }
        } else {
          //getReplyContainerSafe(postContainer, parentReplyId);    // TODO: add parentReplyId is exist
        };

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

    public entry fun deletePost(
        postCollection: &mut PostCollection,
        _userAddr: address,
        postId: u64,
    ) {
        let post = getMutablePost(postCollection, postId);

        // TODO: add check role
        
        // TODO: add
        // if (postContainer.info.postType != PostType.Documentation) {
        //     uint256 time = CommonLib.getTimestamp();
        //     if (time - postContainer.info.postTime < DELETE_TIME || userAddr == postContainer.info.author) {
        //         VoteLib.StructRating memory typeRating = getTypesRating(postContainer.info.postType);
        //         (int32 positive, int32 negative) = getHistoryInformations(postContainer.historyVotes, postContainer.votedUsers);

        //         int32 changeUserRating = typeRating.upvotedPost * positive + typeRating.downvotedPost * negative;
        //         if (changeUserRating > 0) {
        //             self.peeranhaUser.updateUserRating(
        //                 postContainer.info.author,
        //                 -changeUserRating,
        //                 postContainer.info.communityId
        //             );
        //         }
        //     }
        //     if (postContainer.info.bestReply != 0) {
        //         self.peeranhaUser.updateUserRating(postContainer.info.author, -VoteLib.getUserRatingChangeForReplyAction(postContainer.info.postType, VoteLib.ResourceAction.AcceptedReply), postContainer.info.communityId);
        //     }

        //     if (time - postContainer.info.postTime < DELETE_TIME) {
        //         for (uint16 i = 1; i <= postContainer.info.replyCount; i++) {
        //             deductReplyRating(self, postContainer.info.postType, postContainer.replies[i], postContainer.info.bestReply == i, postContainer.info.communityId);
        //         }
        //     }

        //     if (userAddr == postContainer.info.author)
        //         self.peeranhaUser.updateUserRating(postContainer.info.author, VoteLib.DeleteOwnPost, postContainer.info.communityId);
        //     else
        //         self.peeranhaUser.updateUserRating(postContainer.info.author, VoteLib.ModeratorDeletePost, postContainer.info.communityId);
        // }

        post.isDeleted = true;
        // TODO: add emit PostDeleted(userAddr, postId);
    }

    public entry fun deleteReply(
        postCollection: &mut PostCollection,
        _userAddr: address,
        postId: u64,
        replyId: u64,
    ) {
        let post = getMutablePost(postCollection, postId);
        let reply = getMutableReply(post, replyId);

        // TODO: add check role

        //
        // bug
        // checkActionRole has check "require(actionCaller == dataUser, "not_allowed_delete");"
        // behind this check is "if actionCaller == moderator -> return"
        // in this step can be only a moderator or reply's owner
        // a reply owner can not delete best reply, but a moderator can
        // next require check that reply's owner can not delete best reply
        // bug if reply's owner is moderator any way error
        //
        
        // assert!(userAddr != reply.author || post.bestReply != replyId, 45);      // error Invalid immutable borrow at field 'bestReply'.?

        // TODO: add
        // uint256 time = CommonLib.getTimestamp();
        // if (time - replyContainer.info.postTime < DELETE_TIME || userAddr == replyContainer.info.author) {
        //     deductReplyRating(
        //         self,
        //         postContainer.info.postType,
        //         replyContainer,
        //         replyContainer.info.parentReplyId == 0 && postContainer.info.bestReply == replyId,
        //         postContainer.info.communityId
        //     );
        // }
        // if (userAddr == replyContainer.info.author)
        //     self.peeranhaUser.updateUserRating(replyContainer.info.author, VoteLib.DeleteOwnReply, postContainer.info.communityId);
        // else
        //     self.peeranhaUser.updateUserRating(replyContainer.info.author, VoteLib.ModeratorDeleteReply, postContainer.info.communityId);

        reply.isDeleted = true;
        post.deletedReplyCount = post.deletedReplyCount + 1;
        if (post.bestReply == replyId)
            post.bestReply = 0;

        if (post.officialReply == replyId)
            post.officialReply = 0;

        // TODO: add emit ReplyDeleted(userAddr, postId, replyId);
    }

    public entry fun deleteComment(
        postCollection: &mut PostCollection,
        userAddr: address,
        postId: u64,
        parentReplyId: u64,
        commentId: u64,
    ) {
        let post = getMutablePost(postCollection, postId);
        let comment = getMutableComment (post, parentReplyId, commentId);

        // TODO: add check role

        if (userAddr != comment.author) {
            // TODO: add
            // self.peeranhaUser.updateUserRating(commentContainer.info.author, VoteLib.ModeratorDeleteComment, postContainer.info.communityId);
        };

        comment.isDeleted = true;
        // TODO: add emit CommentDeleted(userAddr, postId, parentReplyId, commentId);
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

    // for unitTests
    public fun getPostDataFirst(postCollection: &mut PostCollection, postId: u64): (vector<u8>, u64, address, u64, u64, u64, u64, u8, bool, vector<u64>,   vector<u8>, vector<u128>, vector<address>) {
        let post = vector::borrow(&mut postCollection.posts, postId);
        (
            commonLib::getIpfsHash(post.ipfsDoc),
            post.postTime,
            post.author,
            post.rating,
            post.communityId,
            post.officialReply,
            post.bestReply,
            post.deletedReplyCount,
            post.isDeleted,
            post.tags,
            post.properties,
            post.historyVotes,
            post.votedUsers
        )
    }

    // tags: vector<u64>,
    // replies: vector<Reply>,  // add
    // comments: vector<Comment>,   //add
    // properties: vector<u8>,

    public entry fun set_value(ctx: &mut TxContext) {       // do something with tx_context
        assert!(tx_context::sender(ctx) == tx_context::sender(ctx), 0);
    }
}

#[test_only]
module basics::postLib_test {
    use sui::test_scenario;
    // use basics::userLib;
    use basics::communityLib;
    use basics::postLib;

    #[test]
    fun test_user() {
        let owner = @0xC0FFEE;
        let user1 = @0xA1;

        let scenario = &mut test_scenario::begin(&user1);

        test_scenario::next_tx(scenario, &owner);
        {
            // userLib::initUserCollection(test_scenario::ctx(scenario));
            communityLib::initCommunityCollection(test_scenario::ctx(scenario));
            postLib::initPostCollection(test_scenario::ctx(scenario));
        };

        // create post
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);
            let post_wrapper = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);

            communityLib::createCommunity(
                communityCollection,
                user1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<vector<u8>>[
                    x"0000000000000000000000000000000000000000000000000000000000000001",
                    x"0000000000000000000000000000000000000000000000000000000000000002",
                    x"0000000000000000000000000000000000000000000000000000000000000003",
                    x"0000000000000000000000000000000000000000000000000000000000000004",
                    x"0000000000000000000000000000000000000000000000000000000000000005"
                ]
            );

            postLib::createPost(
                postCollection,
                communityCollection,
                user1,
                0,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2]
            );


// let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 1);
//             assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
//             assert!(timeCreate == 0, 2);
//             assert!(isFrozen == false, 3);
//             assert!(tags == communityLib::unitTestGetCommunityTags(
//                 x"0000000000000000000000000000000000000000000000000000000000000010",
//                 x"0000000000000000000000000000000000000000000000000000000000000011",
//                 x"0000000000000000000000000000000000000000000000000000000000000012",
//                 x"0000000000000000000000000000000000000000000000000000000000000013",
//                 x"0000000000000000000000000000000000000000000000000000000000000014"
//             ), 5);


            test_scenario::return_shared(scenario, community_wrapper);
            test_scenario::return_shared(scenario, post_wrapper);
        };

        // x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1"
        // x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82"
        // x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6"
        // userLib::printUser(userCollection, user1);
    }
}

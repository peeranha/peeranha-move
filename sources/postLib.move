module basics::postLib {    
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use basics::communityLib;
    use basics::commonLib;
    use basics::userLib;
    use basics::i64Lib;

    /* errors */

    const E_INVALID_POST_TYPE: u64 = 31;

    const E_INVALID_RESOURCE_TYPE: u64 = 32;

    const E_ITEM_ID_CAN_NOT_BE_0: u64 = 40;

    const E_USER_CAN_NOT_PUBLISH_2_REPLIES_FOR_EXPERT_AND_COMMON_POSTS: u64 = 41;

    const E_YOU_CAN_NOT_EDIT_THIS_POST_IT_IS_NOT_YOUR: u64 = 42;

    const E_YOU_CAN_NOT_EDIT_THIS_REPLY_IT_IS_NOT_YOUR: u64 = 43;

    const E_YOU_CAN_NOT_EDIT_THIS_COMMENT_IT_IS_NOT_YOUR: u64 = 44;

    const E_YOU_CAN_NOT_DELETE_THE_BEST_REPLY: u64 = 45;

    const E_YOU_CAN_NOT_PUBLISH_REPLIES_IN_TUTORIAL_OR_DOCUMENTATION: u64 = 46;

    const E_USER_IS_FORBIDDEN_TO_REPLY_ON_REPLY_FOR_EXPERT_AND_COMMON_TYPE_OF_POST: u64 = 47;

    const E_YOU_CAN_NOT_PUBLISH_COMMENTS_IN_DOCUMENTATION: u64 = 48;

    const E_THIS_POST_TYPE_IS_ALREADY_SET: u64 = 49;

    const E_ERROR_POST_TYPE: u64 = 50;      ///

    const E_ERROR_VOTE_COMMENT: u64 = 51;

    const E_ERROR_VOTE_REPLY: u64 = 52;

    const E_ERROR_VOTE_POST: u64 = 53;

    const E_YOU_CAN_NOT_VOTE_TO_DOCUMENTATION: u64 = 54;

    const E_POST_NOT_EXIST: u64 = 55;

    const E_REPLY_NOT_EXIST: u64 = 56;

    const E_COMMENT_NOT_EXIST: u64 = 57;

    const E_POST_DELETED: u64 = 58;

    const E_REPLY_DELETED: u64 = 59;

    const E_COMMENT_DELETED: u64 = 60;

    const E_AT_LEAST_ONE_TAG_IS_REQUIRED: u64 = 86;

    // 98, 99 - getPeriodRating  ???

    const QUICK_REPLY_TIME_SECONDS: u64 = 900; // 6
    const DELETE_TIME: u64 = 604800;    //7 days

    // TODO: add enum PostType
    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TYTORIAL: u8 = 2;
    const DOCUMENTATION: u8 = 3;

    const DIRECTION_DOWNVOTE: u8 = 4;
    const DIRECTION_CANCEL_DOWNVOTE: u8 = 0;
    const DIRECTION_UPVOTE: u8 = 3;
    const DIRECTION_CANCEL_UPVOTE: u8 = 1;

    // TODO: add enum TypeContent
    const TYPE_CONTENT_POST: u8 = 0;
    const TYPE_CONTENT_REPLY: u8 = 1;
    const TYPE_CONTENT_COMMENT: u8 = 2;

    struct PostCollection has key {
        id: UID,
        posts: vector<Post>,
    }

    struct Post has store, drop {
        postType: u8,
        ipfsDoc: commonLib::IpfsHash,
        postTime: u64,
        author: address,
        rating: i64Lib::I64,
        communityId: u64,

        officialReply: u64,
        bestReply: u64,
        deletedReplyCount: u64,
        isDeleted: bool,

        tags: vector<u64>,
        replies: vector<Reply>,
        comments: vector<Comment>,
        properties: vector<u8>,

        historyVotes: vector<u8>,                 // downVote = 1, NONE = 2, upVote = 3
        votedUsers: vector<address>
    }

    struct Reply has store, drop, copy {
        ipfsDoc: commonLib::IpfsHash,
        postTime: u64,
        author: address,
        rating: i64Lib::I64,
        parentReplyId: u64,
        
        isFirstReply: bool,
        isQuickReply: bool,
        isDeleted: bool,

        comments: vector<Comment>,
        properties: vector<u8>,
        historyVotes: vector<u8>,                 // to u128?   // 1 - negative, 2 - positive
        votedUsers: vector<address>
    }

    struct Comment has store, drop, copy {
        ipfsDoc: commonLib::IpfsHash,
        postTime: u64,
        author: address,
        rating: i64Lib::I64,

        isDeleted: bool,
        properties: vector<u8>,
        historyVotes: vector<u8>,                 // to u128?   // 1 - negative, 2 - positive
        votedUsers: vector<address>
    }

    struct UserRatingChange has drop {
        user: address,
        rating: i64Lib::I64
    }
   
    fun init(ctx: &mut TxContext) {
        transfer::share_object(PostCollection {
            id: object::new(ctx),
            posts: vector::empty<Post>(),
        })
    }

    #[test_only]    // call?
    public fun init_test(ctx: &mut TxContext) {
        init(ctx)
    }

    public entry fun createPost(
        postCollection: &mut PostCollection,
        communityCollection: &mut communityLib::CommunityCollection,
        userCollection: &mut userLib::UserCollection,
        communityId: u64,
        ipfsHash: vector<u8>, 
        postType: u8,
        tags: vector<u64>,
        ctx: &mut TxContext
    ) {
        let userAddr = tx_context::sender(ctx);

        communityLib::onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        communityLib::checkTags(communityCollection, communityId, tags);

        // TODO: add check role
        userLib::checkActionRole(
            userCollection,
            userAddr,
            userAddr,
            communityId,
            1, // userLib::ACTION_PUBLICATION_POST, (import constant)
            true
        );

        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIphsHash());

        vector::push_back(&mut postCollection.posts, Post {
            postType: postType,
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            postTime: commonLib::getTimestamp(),
            author: userAddr,
            rating: i64Lib::zero(),
            communityId: communityId,
            officialReply: 0,
            bestReply: 0,
            deletedReplyCount: 0,
            isDeleted: false,
            tags: vector::empty<u64>(),
            replies: vector::empty<Reply>(),
            comments: vector::empty<Comment>(),
            properties: vector::empty<u8>(),
            historyVotes: vector::empty<u8>(),
            votedUsers: vector::empty<address>(),
        });
        
        if (postType != DOCUMENTATION) {
            assert!(vector::length(&mut tags) > 0, E_AT_LEAST_ONE_TAG_IS_REQUIRED);
            let postId = vector::length(&mut postCollection.posts);
            let post = getPostContainer(postCollection, postId);
            post.tags = tags;
        };

        // TODO: add emit PostCreated(userAddr, communityId, self.postCount);
    }

    public entry fun createReply(
        postCollection: &mut PostCollection,
        postId: u64,
        parentReplyId: u64,
        ipfsHash: vector<u8>,
        isOfficialReply: bool,
        ctx: &mut TxContext
    ) {
        let userAddr = tx_context::sender(ctx);

        let post = getPostContainer(postCollection, postId);
        assert!(post.postType != TYTORIAL && post.postType != DOCUMENTATION, E_YOU_CAN_NOT_PUBLISH_REPLIES_IN_TUTORIAL_OR_DOCUMENTATION);
        assert!(parentReplyId == 0 || (post.postType != EXPERT_POST && post.postType != COMMON_POST), E_USER_IS_FORBIDDEN_TO_REPLY_ON_REPLY_FOR_EXPERT_AND_COMMON_TYPE_OF_POST);

        // TODO: add check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIphsHash());


        if (post.postType == EXPERT_POST || post.postType == COMMON_POST) {
            let countReplies = vector::length(&post.replies);

            let replyId = 0;
            while (replyId < countReplies) {
                let replyContainer = getReplyContainer(post, replyId);
                assert!(
                    userAddr != replyContainer.author || replyContainer.isDeleted,
                    E_USER_CAN_NOT_PUBLISH_2_REPLIES_FOR_EXPERT_AND_COMMON_POSTS
                );
            };
        };

        let isFirstReply = false;
        let isQuickReply = false;
        let timestamp: u64 = commonLib::getTimestamp();
        if (parentReplyId == 0) {
            if (isOfficialReply) {
                post.officialReply = vector::length(&mut post.replies);
            };

            if (post.postType != TYTORIAL && post.author != userAddr) {
                if (vector::length(&mut post.replies) - post.deletedReplyCount == 0) {    // unit test
                    isFirstReply = true;
                    // TODO: add
                    // self.peeranhaUser.updateUserRating(userAddr, VoteLib.getUserRatingChangeForReplyAction(postContainer.info.postType, VoteLib.ResourceAction.FirstReply), postContainer.info.communityId);
                };

                if (timestamp - post.postTime < QUICK_REPLY_TIME_SECONDS) {
                    isQuickReply = true;   
                    // TODO: add
                    // self.peeranhaUser.updateUserRating(userAddr, VoteLib.getUserRatingChangeForReplyAction(postContainer.info.postType, VoteLib.ResourceAction.QuickReply), postContainer.info.communityId);
                }
            };
        } else {
            //getReplyContainerSafe(postContainer, parentReplyId);    // TODO: add check parentReplyId is exist
        };

        vector::push_back(&mut post.replies, Reply {
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            postTime: timestamp,
            author: userAddr,
            rating: i64Lib::zero(),
            parentReplyId: parentReplyId,
            
            isFirstReply: isFirstReply,
            isQuickReply: isQuickReply,
            isDeleted: false,

            comments: vector::empty<Comment>(),
            properties: vector::empty<u8>(),
            historyVotes: vector::empty<u8>(),
            votedUsers: vector::empty<address>(),
        });

        // TODO: add emit ReplyCreated(userAddr, postId, parentReplyId, postContainer.info.replyCount);
    }

    public entry fun createComment(
        postCollection: &mut PostCollection,
        postId: u64,
        parentReplyId: u64,
        ipfsHash: vector<u8>,
        ctx: &mut TxContext
    ) {
        let userAddr = tx_context::sender(ctx);

        let post = getPostContainer(postCollection, postId);
        assert!(post.postType != DOCUMENTATION, E_YOU_CAN_NOT_PUBLISH_COMMENTS_IN_DOCUMENTATION);
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIphsHash());
        
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
                rating: i64Lib::zero(),
                isDeleted: false,

                properties: vector::empty<u8>(),
                historyVotes: vector::empty<u8>(),
                votedUsers: vector::empty<address>(),
            });
        } else {
            let reply = getReplyContainerSafe(post, parentReplyId);
            vector::push_back(&mut reply.comments, Comment {
                ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
                postTime: 0,            // TODO: add get time
                author: userAddr,
                rating: i64Lib::zero(),
                isDeleted: false,

                properties: vector::empty<u8>(),
                historyVotes: vector::empty<u8>(),
                votedUsers: vector::empty<address>(),
            });
        }
        // TODO: add emit CommentCreated(userAddr, postId, parentReplyId, commentId);
    }

    public entry fun editPost(
        postCollection: &mut PostCollection,
        communityCollection: &mut communityLib::CommunityCollection,
        postId: u64,
        ipfsHash: vector<u8>, 
        tags: vector<u64>,
        ctx: &mut TxContext
    ) {
        let userAddr = tx_context::sender(ctx);

        let post = getPostContainer(postCollection, postId);

        // TODO: add check role
        
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIphsHash());
        assert!(userAddr == post.author || post.postType == DOCUMENTATION, E_YOU_CAN_NOT_EDIT_THIS_POST_IT_IS_NOT_YOUR);

        if(!commonLib::isEmptyIpfs(ipfsHash) && commonLib::getIpfsHash(post.ipfsDoc) != ipfsHash)
            post.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
        if (vector::length(&tags) > 0) {
            communityLib::checkTags(communityCollection, post.communityId, post.tags);
            post.tags = tags;
        }

        // TODO: add emit PostEdited(userAddr, postId);
    }

    public entry fun editReply(
        postCollection: &mut PostCollection,
        postId: u64,
        replyId: u64,
        ipfsHash: vector<u8>, 
        isOfficialReply: bool,
        ctx: &mut TxContext
    ) {
        let userAddr = tx_context::sender(ctx);

        let post = getPostContainer(postCollection, postId);
        let reply = getReplyContainerSafe(post, replyId);

        // TODO: add check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIphsHash());
        assert!(userAddr == reply.author, E_YOU_CAN_NOT_EDIT_THIS_REPLY_IT_IS_NOT_YOUR);

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
        postId: u64,
        parentReplyId: u64,
        commentId: u64,
        ipfsHash: vector<u8>,
        ctx: &mut TxContext
    ) {
        let userAddr = tx_context::sender(ctx);

        let post = getPostContainer(postCollection, postId);
        let comment = getCommentContainerSafe(post, parentReplyId, commentId);

        // TODO: add check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIphsHash());
        assert!(userAddr == comment.author, E_YOU_CAN_NOT_EDIT_THIS_COMMENT_IT_IS_NOT_YOUR);

        if (commonLib::getIpfsHash(comment.ipfsDoc) != ipfsHash)
            comment.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        // TODO: add emit CommentEdited(userAddr, postId, parentReplyId, commentId);
    }

    public entry fun deletePost(
        postCollection: &mut PostCollection,
        userCollection: &mut userLib::UserCollection,
        postId: u64,
        ctx: &mut TxContext
    ) {
        let userAddr = tx_context::sender(ctx);

        let post = getPostContainer(postCollection, postId);

        // TODO: add check role

        post.isDeleted = true;
        // TODO: add emit PostDeleted(userAddr, postId);

        if (post.postType != DOCUMENTATION) {
            let time: u64 = commonLib::getTimestamp();
            if (time - post.postTime < DELETE_TIME || userAddr == post.author) {
                // TODO: add
                let typeRating: StructRating = getTypesRating(post.postType);
                let (positive, negative) = getHistoryInformations(post.historyVotes, post.votedUsers);

                let changeUserRating: i64Lib::I64 = i64Lib::add(&i64Lib::mul(&typeRating.upvotedPost, &i64Lib::from(positive)), &i64Lib::mul(&typeRating.downvotedPost, &i64Lib::from(negative)));
                if (i64Lib::compare(&changeUserRating, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                    // TODO: add
                    // self.peeranhaUser.updateUserRating(
                    //     postContainer.info.author,
                    //     -changeUserRating,
                    //     postContainer.info.communityId
                    // );
                };
            };
            if (post.bestReply != 0) {
                // TODO: add
                // self.peeranhaUser.updateUserRating(postContainer.info.author, -VoteLib.getUserRatingChangeForReplyAction(postContainer.info.postType, VoteLib.ResourceAction.AcceptedReply), postContainer.info.communityId);
            };

            let postAuthor = post.author;
            if (time - post.postTime < DELETE_TIME) {
                let replyCount = vector::length(&post.replies);
                let replyId = 0;
                while (replyId < replyCount) {
                    deductReplyRating(
                        postCollection,
                        userCollection,
                        postId,
                        replyId + 1
                    );
                    replyId = replyId + 1;
                }
            };

            if (userAddr == postAuthor) {
                // TODO: add 
                // self.peeranhaUser.updateUserRating(postContainer.info.author, VoteLib.DeleteOwnPost, postContainer.info.communityId);
            } else {
                // TODO: add 
                // self.peeranhaUser.updateUserRating(postContainer.info.author, VoteLib.ModeratorDeletePost, postContainer.info.communityId);
            };
        };
    }

    public entry fun deleteReply(
        postCollection: &mut PostCollection,
        userCollection: &mut userLib::UserCollection,
        postId: u64,
        replyId: u64,
        ctx: &mut TxContext
    ) {
        let userAddr = tx_context::sender(ctx);

        let post = getPostContainer(postCollection, postId);
        let reply = getReplyContainerSafe(post, replyId);

        // TODO: add check role
        
        // assert!(userAddr != reply.author || post.bestReply != replyId, E_CAN_NOT_DELETE_THE_BEST_REPLY);      // TODO: add  error Invalid immutable borrow at field 'bestReply'.?

        
        let time: u64 = commonLib::getTimestamp();
        let isDeductReplyRating = time - reply.postTime < DELETE_TIME || userAddr == reply.author; // TODO: add ???
        if (userAddr == reply.author) {
            // TODO: add
            // self.peeranhaUser.updateUserRating(replyContainer.info.author, VoteLib.DeleteOwnReply, postContainer.info.communityId);
        } else {
            // TODO: add
            // self.peeranhaUser.updateUserRating(replyContainer.info.author, VoteLib.ModeratorDeleteReply, postContainer.info.communityId);
        };
        
        reply.isDeleted = true;
        post.deletedReplyCount = post.deletedReplyCount + 1;

        if (post.bestReply == replyId)
            post.bestReply = 0;

        if (post.officialReply == replyId)
            post.officialReply = 0;

        if (isDeductReplyRating) {
            deductReplyRating(
                postCollection,
                userCollection,
                postId,
                replyId
            );
        };

        // TODO: add emit ReplyDeleted(userAddr, postId, replyId);
    }


    fun deductReplyRating(
        postCollection: &mut PostCollection,
        _userCollection: &mut userLib::UserCollection,
        postId: u64,
        replyId: u64,
    ) {
        let post = getPostContainer(postCollection, postId);
        let reply = *getReplyContainer(post, replyId);

        let postType = post.postType;
        let isBestReply = reply.parentReplyId == 0 && post.bestReply == replyId;
        let _communityId = post.communityId;

        // TODO: add
        // if (CommonLib.isEmptyIpfs(replyContainer.info.ipfsDoc.hash) || replyContainer.info.isDeleted)
            // return;
        
        let changeReplyAuthorRating: i64Lib::I64 = i64Lib::zero();
        if (i64Lib::compare(&reply.rating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&reply.rating, &i64Lib::zero()) == i64Lib::getEual()) {  //reply.rating >= 0
            if (reply.isFirstReply) {// -=?
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_FIRST_REPLY));
            };
            if (reply.isQuickReply) {// -=?
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_QUICK_REPLY));
            };
            if (isBestReply && postType != TYTORIAL) {// -=?
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPT_REPLY));
            };
        };

        // change user rating considering reply rating
        let typeRating: StructRating = getTypesRating(postType);
        let (positive, negative) = getHistoryInformations(reply.historyVotes, reply.votedUsers);
        
        // typeRating.upvotedReply * positive + typeRating.downvotedReply * negative;
        let changeUserRating: i64Lib::I64 = i64Lib::add(&i64Lib::mul(&typeRating.upvotedReply, &i64Lib::from(positive)), &i64Lib::mul(&typeRating.downvotedReply, &i64Lib::from(negative)));
        
        if (i64Lib::compare(&changeUserRating, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
            changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &changeUserRating); // -=?
        };

        if (i64Lib::compare(&changeReplyAuthorRating, &i64Lib::zero()) != i64Lib::getEual()) {
            // TODO: add
            // self.peeranhaUser.updateUserRating(
            //     replyContainer.info.author, 
            //     changeReplyAuthorRating,
            //     communityId
            // );
        };
    }

    public entry fun deleteComment(
        postCollection: &mut PostCollection,
        postId: u64,
        parentReplyId: u64,
        commentId: u64,
        ctx: &mut TxContext
    ) {
        let userAddr = tx_context::sender(ctx);

        let post = getPostContainer(postCollection, postId);
        let comment = getCommentContainerSafe(post, parentReplyId, commentId);

        // TODO: add check role

        if (userAddr != comment.author) {
            // TODO: add
            // self.peeranhaUser.updateUserRating(commentContainer.info.author, VoteLib.ModeratorDeleteComment, postContainer.info.communityId);
        };

        comment.isDeleted = true;
        // TODO: add emit CommentDeleted(userAddr, postId, parentReplyId, commentId);
    }

    public entry fun voteForumItem(
        postCollection: &mut PostCollection,
        userCollection: &mut userLib::UserCollection,
        postId: u64,
        replyId: u64,
        commentId: u64,
        isUpvote: bool,
        ctx: &mut TxContext
    ) {
        let userAddr = tx_context::sender(ctx);

        let _voteDirection: u8 = 0;
        if (commentId != 0) {
            // TODO: add
            _voteDirection = voteComment(postCollection, userCollection, postId, replyId, commentId, userAddr, isUpvote);
        } else if (replyId != 0) {
            // TODO: add
            // Invalid immutable borrow at field 'communityId'.
            // postLib.move(474, 25): It is still being mutably borrowed by this reference  // reply, post.communityId
            _voteDirection = voteReply(postCollection, userCollection, postId, replyId, userAddr, isUpvote, );
        } else {
            // TODO: add 
            // Invalid usage of reference as function argument. Cannot transfer a mutable reference that is being borrowed  // double ref "postCollection, post"
            _voteDirection = votePost(postCollection, userCollection, postId, userAddr, isUpvote);
        };

        // TODO: add
        // emit ForumItemVoted(userAddr, postId, replyId, commentId, voteDirection);
    }

    ///
    // double ref:
    // postCollection: &mut PostCollection,
    // post: &mut Post,
    //
    // ERROR: 
    // Invalid usage of reference as function argument. Cannot transfer a mutable reference that is being borrowed
    // postLib.move(455, 20): It is still being mutably borrowed by this reference
    ///
    fun votePost(
        postCollection: &mut PostCollection,
        userCollection: &mut userLib::UserCollection,
        postId: u64,
        votedUser: address,
        isUpvote: bool
    ): u8 {
        let post = getPostContainer(postCollection, postId);
        let postType = post.postType;
        assert!(postType != DOCUMENTATION, E_YOU_CAN_NOT_VOTE_TO_DOCUMENTATION);
        assert!(votedUser != post.author, E_ERROR_VOTE_POST);
        
        let (ratingChange, isCancel) = getForumItemRatingChange(votedUser, &mut post.historyVotes, isUpvote, &mut post.votedUsers);
        // TODO: add check role

        // TODO: add
        // Invalid usage of reference as function argument. Cannot transfer a mutable reference that is being borrowed
        // postLib.move(506, 20): It is still being mutably borrowed by this reference
        vote(userCollection, post.author, votedUser, postType, isUpvote, ratingChange, TYPE_CONTENT_POST, post.communityId);
        post.rating = i64Lib::add(&post.rating, &ratingChange);

        if (isCancel) {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                DIRECTION_CANCEL_DOWNVOTE
            } else {
                DIRECTION_CANCEL_UPVOTE
            }
        } else {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                DIRECTION_UPVOTE
            } else {
                DIRECTION_DOWNVOTE
            }
        }
    }

    fun voteReply(
        postCollection: &mut PostCollection,
        userCollection: &mut userLib::UserCollection,
        postId: u64,
        replyId: u64,
        votedUser: address,
        isUpvote: bool
    ): u8 {
        let post = getPostContainer(postCollection, postId);
        let reply = getReplyContainerSafe(post, replyId);
        assert!(votedUser != reply.author, E_ERROR_VOTE_REPLY);

        let (ratingChange, isCancel) = getForumItemRatingChange(votedUser, &mut reply.historyVotes, isUpvote, &mut reply.votedUsers);

        // TODO: add check role

        let oldRating: i64Lib::I64 = reply.rating;
        reply.rating = i64Lib::add(&reply.rating, &ratingChange);
        let newRating: i64Lib::I64 = reply.rating;

        if (reply.isFirstReply) {  // oldRating < 0 && newRating >= 0
            if (i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getLessThan() && (i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getEual())) {
                // TODO: add
                // self.peeranhaUser.updateUserRating(replyContainer.info.author, VoteLib.getUserRatingChangeForReplyAction(postType, VoteLib.ResourceAction.FirstReply), communityId);
            } else if ((i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getEual()) && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getLessThan()) { // (oldRating >= 0 && newRating < 0)
                // TODO: add
                // self.peeranhaUser.updateUserRating(replyContainer.info.author, -VoteLib.getUserRatingChangeForReplyAction(postType, VoteLib.ResourceAction.FirstReply), communityId);
            };
        };

        if (reply.isQuickReply) { //oldRating < 0 && newRating >= 0
            if (i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getLessThan() && (i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getEual())) {
                // TODO: add check role
                // self.peeranhaUser.updateUserRating(replyContainer.info.author, VoteLib.getUserRatingChangeForReplyAction(postType, VoteLib.ResourceAction.QuickReply), communityId);
            } else if ((i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getEual()) && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getLessThan()) { // oldRating >= 0 && newRating < 0
                // TODO: add check role
                // self.peeranhaUser.updateUserRating(replyContainer.info.author, -VoteLib.getUserRatingChangeForReplyAction(postType, VoteLib.ResourceAction.QuickReply), communityId);
            };
        };
        
        vote(userCollection, reply.author, votedUser, post.postType, isUpvote, ratingChange, TYPE_CONTENT_REPLY, post.communityId);
        
        if (isCancel) {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                DIRECTION_CANCEL_DOWNVOTE
            } else {
                DIRECTION_CANCEL_UPVOTE
            }
        } else {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                DIRECTION_UPVOTE
            } else {
                DIRECTION_DOWNVOTE
            }
        }
    }

    fun voteComment(
        postCollection: &mut PostCollection,
        _userCollection: &mut userLib::UserCollection,
        postId: u64,
        replyId: u64,
        commentId: u64,
        votedUser: address,
        isUpvote: bool
    ): u8 {
        let post = getPostContainer(postCollection, postId);
        let comment = getCommentContainerSafe(post, replyId, commentId);
        assert!(votedUser != comment.author, E_ERROR_VOTE_COMMENT);
        
        let (ratingChange, isCancel) = getForumItemRatingChange(votedUser, &mut comment.historyVotes, isUpvote, &mut comment.votedUsers);
        // TODO: add check role

        comment.rating = i64Lib::add(&comment.rating, &ratingChange);

        if (isCancel) {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                DIRECTION_CANCEL_DOWNVOTE
            } else {
                DIRECTION_CANCEL_UPVOTE
            }
        } else {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                DIRECTION_UPVOTE
            } else {
                DIRECTION_DOWNVOTE
            }
        }
    }

    fun vote(
        _userCollection: &mut userLib::UserCollection,
        author: address,
        votedUser: address,
        postType: u8,
        isUpvote: bool,
        ratingChanged: i64Lib::I64,
        typeContent: u8,
        _communityId: u64
    ) {
        // TODO: add Unused assignment or binding for local '_authorRating'. Consider removing, replacing with '_', or prefixing with '_'
        let _authorRating = i64Lib::zero();      // usersRating[0]
        let votedUserRating = i64Lib::zero();   // usersRating[1]

        if (isUpvote) {
            _authorRating = getUserRatingChange(postType, RESOURCE_ACTION_UPVOTED, typeContent);

            if (i64Lib::compare(&ratingChanged, &i64Lib::from(2)) == i64Lib::getEual()) {
                _authorRating = i64Lib::add(&_authorRating, &i64Lib::mul(&getUserRatingChange(postType, RESOURCE_ACTION_DOWNVOTED, typeContent), &i64Lib::neg_from(1)));
                votedUserRating = i64Lib::mul(&getUserRatingChange(postType, RESOURCE_ACTION_DOWNVOTE, typeContent), &i64Lib::neg_from(1)); 
            };

            if (i64Lib::compare(&ratingChanged, &i64Lib::zero()) == i64Lib::getLessThan()) {
                _authorRating = i64Lib::mul(&_authorRating, &i64Lib::neg_from(1));
                votedUserRating = i64Lib::mul(&votedUserRating, &i64Lib::neg_from(1));
            };
        } else {
            _authorRating = getUserRatingChange(postType, RESOURCE_ACTION_DOWNVOTED, typeContent);
            votedUserRating = getUserRatingChange(postType, RESOURCE_ACTION_DOWNVOTE, typeContent);

            if (i64Lib::compare(&ratingChanged, &i64Lib::neg_from(2)) == i64Lib::getEual()) {
                _authorRating = i64Lib::add(&_authorRating, &i64Lib::mul(&getUserRatingChange(postType, RESOURCE_ACTION_UPVOTED, typeContent), &i64Lib::neg_from(1)));
            };

            if (i64Lib::compare(&ratingChanged, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                _authorRating = i64Lib::mul(&_authorRating, &i64Lib::neg_from(1));
                votedUserRating = i64Lib::mul(&votedUserRating, &i64Lib::neg_from(2));  
            };
        };

        let _usersRating: vector<UserRatingChange> = vector<UserRatingChange>[UserRatingChange{ user: author, rating: _authorRating }, UserRatingChange{ user: votedUser, rating: votedUserRating }];
        // self.peeranhaUser.updateUsersRating(usersRating, communityId);
    }

    public entry fun changePostType(    // TODO: add tests
        postCollection: &mut PostCollection,
        postId: u64,
        newPostType: u8,
        ctx: &mut TxContext
    ) {
        let _userAddr = tx_context::sender(ctx);

        let post = getPostContainer(postCollection, postId);

        // TODO: add check role

        let oldPostType = post.postType;
        assert!(newPostType != oldPostType, E_THIS_POST_TYPE_IS_ALREADY_SET);
        assert!(
            oldPostType != DOCUMENTATION &&
            oldPostType != TYTORIAL &&
            newPostType != DOCUMENTATION &&
            newPostType != TYTORIAL,
                50
        );

        let oldTypeRating: StructRating = getTypesRating(oldPostType);
        let newTypeRating: StructRating = getTypesRating(newPostType);

        let (positive, negative) = getHistoryInformations(post.historyVotes, post.votedUsers);

        let positiveRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.upvotedPost, &oldTypeRating.upvotedPost), &i64Lib::from(positive));
        let negativeRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.downvotedPost, &oldTypeRating.downvotedPost), &i64Lib::from(negative));
        let _changeUserRating = i64Lib::add(&positiveRating, &negativeRating);

        // TODO: add
        // self.peeranhaUser.updateUserRating(postContainer.info.author, changeUserRating, postContainer.info.communityId);

        let replyId = 0;    // value means replyPosition not replyId
        while(replyId < vector::length(&post.replies)) {
            let reply = getReplyContainer(post, replyId);
            let (positive, negative) = getHistoryInformations(reply.historyVotes, reply.votedUsers);

            positiveRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.upvotedReply, &oldTypeRating.upvotedReply), &i64Lib::from(positive));
            negativeRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.downvotedReply, &oldTypeRating.downvotedReply), &i64Lib::from(negative));
            _changeUserRating = i64Lib::add(&positiveRating, &negativeRating);

            if (i64Lib::compare(&reply.rating, &i64Lib::zero()) == i64Lib::getGreaterThan() 
                || i64Lib::compare(&reply.rating, &i64Lib::zero()) == i64Lib::getEual()) {
                if (reply.isFirstReply) {
                    _changeUserRating = i64Lib::add(&_changeUserRating, &i64Lib::sub(&newTypeRating.firstReply, &oldTypeRating.firstReply));
                };
                if (reply.isQuickReply) {
                    _changeUserRating = i64Lib::add(&_changeUserRating, &i64Lib::sub(&newTypeRating.quickReply, &oldTypeRating.quickReply));
                };
            };
            // TODO: add
            // self.peeranhaUser.updateUserRating(replyContainer.info.author, changeUserRating, postContainer.info.communityId);
            replyId = replyId + 1;
        };

        if (post.bestReply != 0) {
            // TODO: add
        //     self.peeranhaUser.updateUserRating(postContainer.info.author, newTypeRating.acceptedReply - oldTypeRating.acceptedReply, postContainer.info.communityId);
        //     self.peeranhaUser.updateUserRating(
        //         getReplyContainerSafe(postContainer, postContainer.info.bestReply).info.author,
        //         newTypeRating.acceptReply - oldTypeRating.acceptReply,
        //         postContainer.info.communityId
        //     );
        };

        post.postType = newPostType;
        // TODO: add
        // emit ChangePostType(userAddr, postId, newPostType);
    }

    fun getTypesRating(        //name?
        postType: u8
    ): StructRating {
        if (postType == EXPERT_POST) {
            getExpertRating()
        } else if (postType == COMMON_POST) {
            getCommonRating()
        } else if (postType == TYTORIAL) {
            getTutorialRating()
        } else {
            abort E_INVALID_POST_TYPE
        }
    }

    fun getHistoryInformations(        //name?
        historyVotes: vector<u8>,
        votedUsers: vector<address>
    ): (u64, u64) {
        let i = 0;
        let positive = 0;
        let negative = 0;
        while(i < vector::length(&votedUsers)) {
            if (vector::borrow(&historyVotes, i) == &1) {
                positive = positive + 1;
            } else if (vector::borrow(&historyVotes, i) == &2) {
                negative = negative + 1;
            };
            i = i +1;
        };
        (positive, negative)
    }

    public fun getPostContainer(postCollection: &mut PostCollection, postId: u64): &mut Post { // getPostContainer -> getPostContainerSafe in solidity to
        assert!(postId > 0, E_ITEM_ID_CAN_NOT_BE_0);
        assert!(vector::length(&postCollection.posts) >= postId, E_POST_NOT_EXIST);
        let post = vector::borrow_mut(&mut postCollection.posts, postId - 1);
        assert!(!post.isDeleted, E_POST_DELETED);
        post
    }
    
    // public fun getMutablePost(postCollection: &mut PostCollection, postId: u64): &mut Post {
    //     assert!(postId > 0, E_ITEM_ID_CAN_NOT_BE_0);
    //     assert!(vector::length(&postCollection.posts) >= postId, E_POST_NOT_EXIST);
    //     let post = vector::borrow_mut(&mut postCollection.posts, postId - 1);
    //     assert!(!post.isDeleted, E_POST_DELETED);
    //     post
    // }

    public fun getReplyContainer(post: &mut Post, replyId: u64): &mut Reply {
        assert!(replyId > 0, E_ITEM_ID_CAN_NOT_BE_0);
        assert!(vector::length(&post.replies) >= replyId, E_REPLY_NOT_EXIST);
        let reply = vector::borrow_mut(&mut post.replies, replyId - 1);
        reply
    }

    public fun getReplyContainerSafe(post: &mut Post, replyId: u64): &mut Reply {
        let reply = getReplyContainer(post, replyId);
        assert!(!reply.isDeleted, E_REPLY_DELETED);
        reply
    }

    // public fun getMutableReplyContainer(post: &Post, replyId: u64): &Reply {
    //     assert!(replyId > 0, E_ITEM_ID_CAN_NOT_BE_0);
    //     assert!(vector::length(&post.replies) >= replyId, E_REPLY_NOT_EXIST);
    //     let reply = vector::borrow(&post.replies, replyId - 1);
    //     assert!(!reply.isDeleted, E_REPLY_DELETED);
    //     reply
    // }

    // public fun getMutableReply(post: &mut Post, replyId: u64): &mut Reply {
    //     assert!(replyId > 0, E_ITEM_ID_CAN_NOT_BE_0);
    //     assert!(vector::length(&post.replies) >= replyId, E_REPLY_NOT_EXIST);
    //     let reply = vector::borrow_mut(&mut post.replies, replyId - 1);
    //     assert!(!reply.isDeleted, E_REPLY_DELETED);
    //     reply
    // }

    public fun getCommentContainer(post: &mut Post, parentReplyId: u64, commentId: u64): &mut Comment {
        assert!(commentId > 0, E_ITEM_ID_CAN_NOT_BE_0);
        if (parentReplyId == 0) {
            assert!(vector::length(&post.comments) >= commentId, E_COMMENT_NOT_EXIST);
            let comment = vector::borrow_mut(&mut post.comments, commentId - 1);
            comment

        } else {
            let reply = getReplyContainerSafe(post, parentReplyId);
            assert!(vector::length(&reply.comments) >= commentId, E_COMMENT_NOT_EXIST);
            let comment = vector::borrow_mut(&mut reply.comments, commentId - 1);
            comment
        }
    }

    public fun getCommentContainerSafe(post: &mut Post, parentReplyId: u64, commentId: u64): &mut Comment {
        let comment = getCommentContainer(post, parentReplyId, commentId);
        assert!(!comment.isDeleted, E_COMMENT_DELETED);
        comment
    }
    
    // public fun getMutableComment (post: &mut Post, parentReplyId: u64, commentId: u64): &mut Comment {
    //     assert!(commentId > 0, E_ITEM_ID_CAN_NOT_BE_0);
    //     if (parentReplyId == 0) {
    //         assert!(vector::length(&post.comments) >= commentId, E_COMMENT_NOT_EXIST);
    //         let comment = vector::borrow_mut(&mut post.comments, commentId - 1);
    //         assert!(!comment.isDeleted, E_COMMENT_DELETED);
    //         comment

    //     } else {
    //         let reply = getReplyContainerSafe(post, parentReplyId);
    //         assert!(vector::length(&reply.comments) >= commentId, E_COMMENT_NOT_EXIST);
    //         let comment = vector::borrow_mut(&mut reply.comments, commentId - 1);
    //         assert!(!comment.isDeleted, E_COMMENT_DELETED);
    //         comment
    //     }
    // }

    public fun getPost(postCollection: &mut PostCollection, postId: u64): &mut Post {
        assert!(postId > 0, E_ITEM_ID_CAN_NOT_BE_0);
        assert!(vector::length(&postCollection.posts) >= postId, E_POST_NOT_EXIST);
        let post = vector::borrow_mut(&mut postCollection.posts, postId - 1);
        post
    }

    public fun getReply(postCollection: &mut PostCollection, postId: u64, replyId: u64): &mut Reply {
        let post = getPost(postCollection, postId);
        return getReplyContainer(post, replyId)
    }

    public fun getComment(postCollection: &mut PostCollection, postId: u64, replyId: u64, commentId: u64): &mut Comment {
        let post = getPost(postCollection, postId);
        return getCommentContainer(post, replyId, commentId)
    }

    #[test_only]
    public fun getPostData(postCollection: &mut PostCollection, postId: u64): (u8, vector<u8>, u64, address, i64Lib::I64, u64, u64, u64, u64, bool, vector<u64>, vector<u8>, vector<u8>, vector<address>) {
        let post = getPost(postCollection, postId);
        (
            post.postType,
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
        // replies: vector<Reply>,  // TODO: add
        // comments: vector<Comment>,   // TODO: add
    }

    #[test_only]
    public fun getReplyData(postCollection: &mut PostCollection, postId: u64, replyId: u64): (vector<u8>, u64, address, i64Lib::I64, u64, bool, bool, bool, vector<u8>, vector<u8>, vector<address>) {
        let reply = getReply(postCollection, postId, replyId);

        (
            commonLib::getIpfsHash(reply.ipfsDoc),
            reply.postTime,
            reply.author,
            reply.rating,
            reply.parentReplyId,
            reply.isFirstReply,
            reply.isQuickReply,
            reply.isDeleted,
            reply.properties,
            reply.historyVotes,
            reply.votedUsers
        )
        // comments: vector<Comment>, // TODO: add
    }

    #[test_only]
    public fun getCommentData(postCollection: &mut PostCollection, postId: u64, parentReplyId: u64, commentId: u64): (vector<u8>, u64, address, i64Lib::I64, bool, vector<u8>, vector<u8>, vector<address>) {
        let comment = getComment(postCollection, postId, parentReplyId, commentId);
        
        (
            commonLib::getIpfsHash(comment.ipfsDoc),
            comment.postTime,
            comment.author,
            comment.rating,

            comment.isDeleted,
            comment.properties,
            comment.historyVotes,
            comment.votedUsers
        )
    }

    #[test_only]
    public fun create_post(
        postCollection: &mut PostCollection,
        communityCollection: &mut communityLib::CommunityCollection,
        userCollection: &mut userLib::UserCollection,
        ctx: &mut TxContext
    ) {
        createPost(
            postCollection,
            communityCollection,
            userCollection,
            1,
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            EXPERT_POST,
            vector<u64>[1, 2],
            ctx
        );
    }

    #[test_only]
    public fun create_post_with_type(
        postCollection: &mut PostCollection,
        communityCollection: &mut communityLib::CommunityCollection,
        userCollection: &mut userLib::UserCollection,
        postType: u8,
        ctx: &mut TxContext
    ) {
        createPost(
            postCollection,
            communityCollection,
            userCollection,
            1,
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            postType,
            vector<u64>[1, 2],
            ctx
        );
    }

    #[test_only]
    public fun create_reply(
        postCollection: &mut PostCollection,
        ctx: &mut TxContext
    ) {
        createReply(
            postCollection,
            1,
            0,
            x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
            false,
            ctx
        );
    }


    ///
    //voteLib
    ///
    struct StructRating has drop {  // TODO: add drop?
        upvotedPost: i64Lib::I64,
        downvotedPost: i64Lib::I64,

        upvotedReply: i64Lib::I64,
        downvotedReply: i64Lib::I64,
        firstReply: i64Lib::I64,
        quickReply: i64Lib::I64,
        acceptReply: i64Lib::I64,
        acceptedReply: i64Lib::I64
    }

    const RESOURCE_ACTION_DOWNVOTE: u8 = 0;
    const RESOURCE_ACTION_UPVOTED: u8 = 1;
    const RESOURCE_ACTION_DOWNVOTED: u8 = 2;
    const RESOURCE_ACTION_ACCEPT_REPLY: u8 = 3;
    const RESOURCE_ACTION_ACCEPTED_REPLY: u8 = 4;
    const RESOURCE_ACTION_FIRST_REPLY: u8 = 5;
    const RESOURCE_ACTION_QUICK_REPLY: u8 = 6;

    //expert post
    const DOWNVOTE_EXPERT_POST: u64 = 1;         // negative
    const UPVOTED_EXPERT_POST: u64 = 5;
    const DOWNVOTED_EXPERT_POST: u64 = 2;       // negative

    //common post 
    const DOWNVOTE_COMMON_POST: u64 = 1;        // negative
    const UPVOTED_COMMON_POST: u64 = 1;
    const DOWNVOTED_COMMON_POST: u64 = 1;       // negative

    //tutorial 
    const DOWNVOTE_TUTORIAL: u64 = 1;           // negative
    const UPVOTED_TUTORIAL: u64 = 5;
    const DOWNVOTED_TUTORIAL: u64 = 2;          // negative

    const DELETE_OWN_POST: u64 = 1;             // negative
    const MODERATOR_DELETE_POST: u64 = 2;       // negative

/////////////////////////////////////////////////////////////////////////////

    //expert reply
    const DOWNVOTE_EXPERT_REPLY: u64 = 1;       // negative
    const UPVOTED_EXPERT_REPLY: u64 = 10;
    const DOWNVOTED_EXPERT_REPLY: u64 = 2;      // negative
    const ACCEPT_EXPERT_REPLY: u64 = 15;
    const ACCEPTED_EXPERT_REPLY: u64 = 2;
    const FIRST_EXPERT_REPLY: u64 = 5;
    const QUICK_EXPERT_REPLY: u64 = 5;

    //common reply 
    const DOWNVOTE_COMMON_REPLY: u64 = 1;       // negative
    const UPVOTED_COMMON_REPLY: u64 = 1;
    const DOWNVOTED_COMMON_REPLY: u64 = 1;      // negative
    const ACCEPT_COMMON_REPLY: u64 = 3;
    const ACCEPTED_COMMON_REPLY: u64 = 1;
    const FIRST_COMMON_REPLY: u64 = 1;
    const QUICK_COMMON_REPLY: u64 = 1;
    
    const DELETE_OWN_REPLY: u64 = 1;            // negative
    const MODERATOR_DELETE_REPLY: u64 = 2;      // negative     // to do

/////////////////////////////////////////////////////////////////////////////////

    const MODERATOR_DELETE_COMMENT: u64 = 1;    // negative

        public fun getExpertRating(): StructRating {
        StructRating {
            upvotedPost: i64Lib::from(UPVOTED_EXPERT_POST),
            downvotedPost: i64Lib::neg_from(DOWNVOTED_EXPERT_POST),

            upvotedReply: i64Lib::from(UPVOTED_EXPERT_REPLY),
            downvotedReply: i64Lib::neg_from(DOWNVOTED_EXPERT_REPLY),
            firstReply: i64Lib::from(FIRST_EXPERT_REPLY),
            quickReply: i64Lib::from(QUICK_EXPERT_REPLY),
            acceptReply: i64Lib::from(ACCEPT_EXPERT_REPLY),
            acceptedReply: i64Lib::from(ACCEPTED_EXPERT_REPLY)
        }
    }

    public fun getCommonRating(): StructRating {
        StructRating {
            upvotedPost: i64Lib::from(UPVOTED_COMMON_POST),
            downvotedPost: i64Lib::neg_from(DOWNVOTED_COMMON_POST),

            upvotedReply: i64Lib::from(UPVOTED_COMMON_REPLY),
            downvotedReply: i64Lib::neg_from(DOWNVOTED_COMMON_REPLY),
            firstReply: i64Lib::from(FIRST_COMMON_REPLY),
            quickReply: i64Lib::from(QUICK_COMMON_REPLY),
            acceptReply: i64Lib::from(ACCEPT_COMMON_REPLY),
            acceptedReply: i64Lib::from(ACCEPTED_COMMON_REPLY)
        }
    }

    public fun getTutorialRating(): StructRating {
        StructRating {
            upvotedPost: i64Lib::from(UPVOTED_TUTORIAL),
            downvotedPost: i64Lib::neg_from(DOWNVOTED_TUTORIAL),

            upvotedReply: i64Lib::zero(),
            downvotedReply: i64Lib::zero(),
            firstReply: i64Lib::zero(),
            quickReply: i64Lib::zero(),
            acceptReply: i64Lib::zero(),
            acceptedReply: i64Lib::zero()
        }
    }

    public fun getUserRatingChangeForPostAction(
        postType: u8,
        resourceAction: u8
    ): i64Lib::I64 {
        if (postType == EXPERT_POST) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_EXPERT_POST)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_EXPERT_POST)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_EXPERT_POST)
            else abort E_INVALID_POST_TYPE

        } else if (postType == COMMON_POST) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_COMMON_POST)
            else abort E_INVALID_POST_TYPE

        } else if (postType == TYTORIAL) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_TUTORIAL)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_TUTORIAL)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_TUTORIAL)
            else abort E_INVALID_POST_TYPE

        } else {
            abort E_INVALID_POST_TYPE
        }
    }

    public fun getUserRatingChangeForReplyAction(
        postType: u8,
        resourceAction: u8
    ): i64Lib::I64 {
        if (postType == EXPERT_POST) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_EXPERT_REPLY)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_EXPERT_REPLY)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_EXPERT_REPLY)
            else if (resourceAction == RESOURCE_ACTION_ACCEPT_REPLY) i64Lib::from(ACCEPT_EXPERT_REPLY)
            else if (resourceAction == RESOURCE_ACTION_ACCEPTED_REPLY) i64Lib::from(ACCEPTED_EXPERT_REPLY)
            else if (resourceAction == RESOURCE_ACTION_FIRST_REPLY) i64Lib::from(FIRST_EXPERT_REPLY)
            else if (resourceAction == RESOURCE_ACTION_QUICK_REPLY) i64Lib::from(QUICK_EXPERT_REPLY)
            else abort E_INVALID_RESOURCE_TYPE

        } else if (postType == COMMON_POST) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_ACCEPT_REPLY) i64Lib::from(ACCEPT_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_ACCEPTED_REPLY) i64Lib::from(ACCEPTED_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_FIRST_REPLY) i64Lib::from(FIRST_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_QUICK_REPLY) i64Lib::from(QUICK_COMMON_REPLY)
            else abort E_INVALID_RESOURCE_TYPE

        } else if (postType == TYTORIAL) {
            i64Lib::zero()

        } else {
            abort E_INVALID_RESOURCE_TYPE
        }
    }

    public fun getUserRatingChange(
        postType: u8,
        resourceAction: u8,
        typeContent: u8 
    ): i64Lib::I64 {
        if (typeContent == TYPE_CONTENT_POST) {
            getUserRatingChangeForPostAction(postType, resourceAction)
        } else if (typeContent == TYPE_CONTENT_REPLY) {
            getUserRatingChangeForReplyAction(postType, resourceAction)
        } else {
            i64Lib::zero()            
        }
    }
    
    public fun getForumItemRatingChange(
        actionAddress: address,
        historyVotes: &mut vector<u8>,
        isUpvote: bool,
        votedUsers: &mut vector<address>
    ): (i64Lib::I64, bool) {
        let (history, userPosition, isExistVote) = getHistoryVote(actionAddress, *historyVotes, *votedUsers);
        // int history = getHistoryVote(actionAddress, historyVotes);
        let ratingChange: i64Lib::I64;
        let isCancel: bool = false;
        
        if (isUpvote) {
            if (history == 1) {
                let userHistoryVote = vector::borrow_mut(historyVotes, userPosition);
                *userHistoryVote = 3;
                ratingChange = i64Lib::from(2);
            } else if (history == 2) {
                if (isExistVote) {
                   let userHistoryVote = vector::borrow_mut(historyVotes, userPosition);
                    *userHistoryVote = 3;
                } else {
                    vector::push_back(votedUsers, actionAddress);
                    vector::push_back(historyVotes, 3);
                };
                ratingChange = i64Lib::from(1);
            } else {
                let userHistoryVote = vector::borrow_mut(historyVotes, userPosition);
                *userHistoryVote = 2;
                ratingChange = i64Lib::neg_from(1);
                isCancel = true;
            };
        } else {
            if (history == 1) {
                let userHistoryVote = vector::borrow_mut(historyVotes, userPosition);
                *userHistoryVote = 2;
                ratingChange = i64Lib::from(1);
                isCancel = true;
            } else if (history == 2) {
                if (isExistVote) {
                    let userHistoryVote = vector::borrow_mut(historyVotes, userPosition);
                    *userHistoryVote = 1;
                } else {
                    vector::push_back(votedUsers, actionAddress);
                    vector::push_back(historyVotes, 1);
                };
                ratingChange = i64Lib::neg_from(1);
            } else {
                let userHistoryVote = vector::borrow_mut(historyVotes, userPosition);
                *userHistoryVote = 1;
                ratingChange = i64Lib::neg_from(2);
            }
        };
        
        (ratingChange, isCancel)
    }  

    // return value:
    // downVote = 1
    // NONE = 2
    // upVote = 3
    public fun getHistoryVote(
        user: address,
        historyVotes: vector<u8>,
        votedUsers: vector<address>
    ): (u8, u64, bool) { // (status vote, isExistVote)
        let (isExist, position) = vector::index_of(&mut votedUsers, &user);

        if (isExist) {
            let voteVolue = vector::borrow(&mut historyVotes, position);
            (*voteVolue, position, true)
        } else {
            (2, 0, false)
        }
    }
}

// #[test_only]
// module basics::postLib_test {
//     use sui::test_scenario;
//     // use basics::userLib;
//     use basics::communityLib;
//     use basics::postLib;

    
// }

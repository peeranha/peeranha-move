module basics::postLib {    
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use basics::communityLib;
    use basics::commonLib;
    use basics::userLib;
    use basics::i64Lib;

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

    struct Reply has store, drop {
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

    struct Comment has store, drop {
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

    public entry fun createPost(
        postCollection: &mut PostCollection,
        communityCollection: &mut communityLib::CommunityCollection,
        userAddr: address,
        communityId: u64,
        ipfsHash: vector<u8>, 
        postType: u8,
        tags: vector<u64>
    ) {
        communityLib::onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        communityLib::checkTags(communityCollection, communityId, tags);
        // TODO: add check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);

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
            assert!(vector::length(&mut tags) > 0, 26);
            let postId = vector::length(&mut postCollection.posts);
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
        assert!(post.postType != TYTORIAL && post.postType != DOCUMENTATION, 46);
        assert!(parentReplyId == 0 || (post.postType != EXPERT_POST && post.postType != COMMON_POST), 47);

        // TODO: add check role
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);


        if (post.postType == EXPERT_POST || post.postType == COMMON_POST) {
            let countReplies = vector::length(&post.replies);

            let replyId = 0;
            while (replyId < countReplies) {
                let replyContainer = getReply(post, replyId);
                assert!(userAddr != replyContainer.author || replyContainer.isDeleted, 41);
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
        userAddr: address,
        postId: u64,
        parentReplyId: u64,
        ipfsHash: vector<u8>, 
    ) {
        let post = getMutablePost(postCollection, postId);
        assert!(post.postType != DOCUMENTATION, 48);
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
                rating: i64Lib::zero(),
                isDeleted: false,

                properties: vector::empty<u8>(),
                historyVotes: vector::empty<u8>(),
                votedUsers: vector::empty<address>(),
            });
        } else {
            let reply = getMutableReply(post, parentReplyId);
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
        userAddr: address,
        postId: u64,
        ipfsHash: vector<u8>, 
        tags: vector<u64>
    ) {
        let post = getMutablePost(postCollection, postId);
        communityLib::checkTags(communityCollection, post.communityId, tags);

        // TODO: add check role
        
        assert!(!commonLib::isEmptyIpfs(ipfsHash), 30);
        assert!(userAddr == post.author || post.postType == DOCUMENTATION, 42);

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
        userCollection: &mut userLib::UserCollection,
        userAddr: address,
        postId: u64,
    ) {
        let post = getMutablePost(postCollection, postId);

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
        userAddr: address,
        postId: u64,
        replyId: u64,
    ) {
        let post = getMutablePost(postCollection, postId);
        let reply = getMutableReply(post, replyId);

        // TODO: add check role
        
        // assert!(userAddr != reply.author || post.bestReply != replyId, 45);      // TODO: add  error Invalid immutable borrow at field 'bestReply'.?

        
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
        let post = getPost(postCollection, postId);
        let reply = getReply(post, replyId);

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

    public entry fun voteForumItem(
        postCollection: &mut PostCollection,
        userCollection: &mut userLib::UserCollection,
        userAddr: address,
        postId: u64,
        replyId: u64,
        commentId: u64,
        isUpvote: bool
    ) {
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
        let post = getMutablePost(postCollection, postId);
        let postType = post.postType;
        assert!(postType != DOCUMENTATION, 54);
        assert!(votedUser != post.author, 53);
        
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
        let post = getMutablePost(postCollection, postId);
        let reply = getMutableReply(post, replyId);
        assert!(votedUser != reply.author, 52);

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
        let post = getMutablePost(postCollection, postId);
        let comment = getMutableComment (post, replyId, commentId);
        assert!(votedUser != comment.author, 51);
        
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
        _userAddr: address,
        postId: u64,
        newPostType: u8
    ) {
        let post = getMutablePost(postCollection, postId);

        // TODO: add check role

        let oldPostType = post.postType;
        assert!(newPostType != oldPostType, 49);
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
            let reply = getReply(post, replyId);
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
            abort 42
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

    public fun getPost(postCollection: &PostCollection, postId: u64): &Post {
        assert!(postId > 0, 40);
        vector::borrow(&postCollection.posts, postId - 1)
    }
    
    public fun getMutablePost(postCollection: &mut PostCollection, postId: u64): &mut Post {
        assert!(postId > 0, 40);
        vector::borrow_mut(&mut postCollection.posts, postId - 1)
    }

    public fun getReply(post: &Post, replyId: u64): &Reply {
        assert!(replyId > 0, 40);
        vector::borrow(&post.replies, replyId - 1)
    }

    public fun getMutableReply(post: &mut Post, replyId: u64): &mut Reply {
        assert!(replyId > 0, 40);
        vector::borrow_mut(&mut post.replies, replyId - 1)
    }

    public fun getComment(post: &Post, parentReplyId: u64, commentId: u64): &Comment {
        assert!(commentId > 0, 40);
        if (parentReplyId == 0) {
            vector::borrow(&post.comments, commentId - 1)
        } else {
            let reply = getReply(post, parentReplyId);
            vector::borrow(&reply.comments, commentId - 1)
        }
        // require(!CommonLib.isEmptyIpfs(commentContainer.info.ipfsDoc.hash), "Comment_not_exist.");
    }
    
    public fun getMutableComment (post: &mut Post, parentReplyId: u64, commentId: u64): &mut Comment {
        assert!(commentId > 0, 40);
        if (parentReplyId == 0) {
            vector::borrow_mut(&mut post.comments, commentId - 1)
        } else {
            let reply = getMutableReply(post, parentReplyId);
            vector::borrow_mut(&mut reply.comments, commentId - 1)
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

    // for unitTests
    public fun getReplyData(postCollection: &mut PostCollection, postId: u64, replyId: u64): (vector<u8>, u64, address, i64Lib::I64, u64, bool, bool, bool, vector<u8>, vector<u8>, vector<address>) {
        let post = getPost(postCollection, postId);
        let reply = getReply(post, replyId);

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

    // for unitTests
    public fun getCommentData(postCollection: &mut PostCollection, postId: u64, parentReplyId: u64, commentId: u64): (vector<u8>, u64, address, i64Lib::I64, bool, vector<u8>, vector<u8>, vector<address>) {
        let post = getPost(postCollection, postId);
        let comment = getComment(post, parentReplyId, commentId);
        
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



    public entry fun set_value(ctx: &mut TxContext) {       // do something with tx_context
        assert!(tx_context::sender(ctx) == tx_context::sender(ctx), 0);
    }

    // create/edit/delete for post/reply/comment
    #[test]
    fun test_create_post() {
        use sui::test_scenario;

        // let owner = @0xC0FFEE;
        let user1 = @0xA1;

        let scenario = &mut test_scenario::begin(&user1);
        {
            // userLib::initUserCollection(test_scenario::ctx(scenario));
            communityLib::initCommunity(test_scenario::ctx(scenario));
            userLib::initUser(test_scenario::ctx(scenario));
            init(test_scenario::ctx(scenario));
        };

        // create expert post
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
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

            createPost(
                postCollection,
                communityCollection,
                user1,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                EXPERT_POST,
                vector<u64>[1, 2]
            );

            let (
                postType,
                ipfsDoc,
                postTime,
                author,
                rating,
                communityId,
                officialReply,
                bestReply,
                deletedReplyCount,
                isDeleted,
                tags,
                properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
            assert!(postTime == 0, 3);
            assert!(author == user1, 4);
            assert!(rating == i64Lib::zero(), 5);
            assert!(communityId == 1, 6);
            assert!(officialReply == 0, 7);
            assert!(bestReply == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[1, 2], 11);
            assert!(properties == vector<u8>[], 12);
            assert!(historyVotes == vector<u8>[], 13);
            assert!(votedUsers == vector<address>[], 14);

            test_scenario::return_shared(scenario, community_wrapper);
            test_scenario::return_shared(scenario, post_wrapper);
        };

        // change post type expert -> common
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            
            changePostType(
                postCollection,
                user1,
                1,
                COMMON_POST,
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = getPostData(postCollection, 1);
            assert!(postType == COMMON_POST, 1);

            changePostType(
                postCollection,
                user1,
                1,
                EXPERT_POST,
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = getPostData(postCollection, 1);
            assert!(postType == EXPERT_POST, 1);

            test_scenario::return_shared(scenario, post_wrapper);
        };

        // edit post
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);

            editPost(
                postCollection,
                communityCollection,
                user1,
                1,
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                vector<u64>[2]
            );

            let (
                postType,
                ipfsDoc,
                postTime,
                author,
                rating,
                communityId,
                officialReply,
                bestReply,
                deletedReplyCount,
                isDeleted,
                tags,
                properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(postType == 0, 1);
            assert!(ipfsDoc == x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc", 2);
            assert!(postTime == 0, 3);
            assert!(author == user1, 4);
            assert!(rating == i64Lib::zero(), 5);
            assert!(communityId == 1, 6);
            assert!(officialReply == 0, 7);
            assert!(bestReply == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[2], 11);
            assert!(properties == vector<u8>[], 12);
            assert!(historyVotes == vector<u8>[], 13);
            assert!(votedUsers == vector<address>[], 14);

            test_scenario::return_shared(scenario, community_wrapper);
            test_scenario::return_shared(scenario, post_wrapper);
        };

        //create reply
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
  
            createReply(
                postCollection,
                user1,
                1,
                0,
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                false
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,
                parentReplyId,
                isFirstReply,
                isQuickReply,
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = getReplyData(postCollection, 1, 1);

            assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
            assert!(postTime == 0, 2);
            assert!(author == user1, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(parentReplyId == 0, 5);
            assert!(isFirstReply == false, 6);
            assert!(isQuickReply == false, 7);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(scenario, post_wrapper);
        };

        //edit reply
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
  
            editReply(
                postCollection,
                user1,
                1,
                1,
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                false
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,
                parentReplyId,
                isFirstReply,
                isQuickReply,
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = getReplyData(postCollection, 1, 1);

            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(postTime == 0, 2);
            assert!(author == user1, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(parentReplyId == 0, 5);
            assert!(isFirstReply == false, 6);
            assert!(isQuickReply == false, 7);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(scenario, post_wrapper);
        };

        //create comment to post
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
  
            createComment(
                postCollection,
                user1,
                1,
                0,
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc"
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,                
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = getCommentData(postCollection, 1, 0, 1);

            assert!(ipfsDoc == x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc", 1);
            assert!(postTime == 0, 2);
            assert!(author == user1, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(scenario, post_wrapper);
        };

        //create comment to reply
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
  
            createComment(
                postCollection,
                user1,
                1,
                1,
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1"
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,                
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = getCommentData(postCollection, 1, 1, 1);

            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(postTime == 0, 2);
            assert!(author == user1, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(scenario, post_wrapper);
        };


        //edit comment to post
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
  
            editComment(
                postCollection,
                user1,
                1,
                0,
                1,
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82"
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,                
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = getCommentData(postCollection, 1, 0, 1);

            assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
            assert!(postTime == 0, 2);
            assert!(author == user1, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(scenario, post_wrapper);
        };

        //edit comment to reply
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
  
            editComment(
                postCollection,
                user1,
                1,
                1,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6"
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,                
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = getCommentData(postCollection, 1, 1, 1);

            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(postTime == 0, 2);
            assert!(author == user1, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(scenario, post_wrapper);
        };

        //delete comment to post
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
  
            deleteComment(
                postCollection,
                user1,
                1,
                0,
                1
            );

            let (
                _ipfsDoc,
                _postTime,
                _author,
                _rating,                
                isDeleted,
                _properties,
                _historyVotes,
                _votedUsers
            ) = getCommentData(postCollection, 1, 0, 1);

            assert!(isDeleted == true, 1);

            test_scenario::return_shared(scenario, post_wrapper);
        };

        //delete comment to reply
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
  
            deleteComment(
                postCollection,
                user1,
                1,
                1,
                1
            );

            let (
                _ipfsDoc,
                _postTime,
                _author,
                _rating,                
                isDeleted,
                _properties,
                _historyVotes,
                _votedUsers
            ) = getCommentData(postCollection, 1, 1, 1);

            assert!(isDeleted == true, 1);

            test_scenario::return_shared(scenario, post_wrapper);
        };

        // delete reply
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
  
            deleteReply(
                postCollection,
                userCollection,
                user1,
                1,
                1,
            );

            let (
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _parentReplyId,
                _isFirstReply,
                _isQuickReply,
                isDeleted,
                _properties,
                _historyVotes,
                _votedUsers
            ) = getReplyData(postCollection, 1, 1);

            assert!(isDeleted == true, 0);

            let (
                _postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                deletedReplyCount,
                isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = getPostData(postCollection, 1);

            assert!(deletedReplyCount == 1, 1);
            assert!(isDeleted == false, 2);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };

        // delete post
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);

            deletePost(
                postCollection,
                userCollection,
                user1,
                1,
            );

            let (
                _postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = getPostData(postCollection, 1);

            assert!(isDeleted == true, 1);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };
    }

    #[test]
    fun test_upvote_post() {
        use sui::test_scenario;

        // let owner = @0xC0FFEE;
        let user1 = @0xA1;
        let user2 = @0xA2;

        let scenario = &mut test_scenario::begin(&user1);
        {
            // userLib::initUserCollection(test_scenario::ctx(scenario));
            communityLib::initCommunity(test_scenario::ctx(scenario));
            userLib::initUser(test_scenario::ctx(scenario));
            init(test_scenario::ctx(scenario));
        };

        
        // create expert post
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
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

            createPost(
                postCollection,
                communityCollection,
                user1,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                EXPERT_POST,
                vector<u64>[1, 2]
            );

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, community_wrapper);
        };
        
        // upvote Post
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                true
            );

            let (
                postType,
                ipfsDoc,
                postTime,
                author,
                rating,
                communityId,
                officialReply,
                bestReply,
                deletedReplyCount,
                isDeleted,
                tags,
                properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
            assert!(postTime == 0, 3);
            assert!(author == user1, 4);
            assert!(rating == i64Lib::from(1), 5);
            assert!(communityId == 1, 6);
            assert!(officialReply == 0, 7);
            assert!(bestReply == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[1, 2], 11);
            assert!(properties == vector<u8>[], 12);
            assert!(historyVotes == vector<u8>[3], 13);
            assert!(votedUsers == vector<address>[user2], 14);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };

        // cancel upvote Post
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                true
            );

            let (
                postType,
                ipfsDoc,
                postTime,
                author,
                rating,
                communityId,
                officialReply,
                bestReply,
                deletedReplyCount,
                isDeleted,
                tags,
                properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
            assert!(postTime == 0, 3);
            assert!(author == user1, 4);
            assert!(rating == i64Lib::from(0), 5);
            assert!(communityId == 1, 6);
            assert!(officialReply == 0, 7);
            assert!(bestReply == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[1, 2], 11);
            assert!(properties == vector<u8>[], 12);
            assert!(historyVotes == vector<u8>[2], 13);
            assert!(votedUsers == vector<address>[user2], 14);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };

        // upvote after cancel upvote Post
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                true
            );

            let (
                postType,
                ipfsDoc,
                postTime,
                author,
                rating,
                communityId,
                officialReply,
                bestReply,
                deletedReplyCount,
                isDeleted,
                tags,
                properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
            assert!(postTime == 0, 3);
            assert!(author == user1, 4);
            assert!(rating == i64Lib::from(1), 5);
            assert!(communityId == 1, 6);
            assert!(officialReply == 0, 7);
            assert!(bestReply == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[1, 2], 11);
            assert!(properties == vector<u8>[], 12);
            assert!(historyVotes == vector<u8>[3], 13);
            assert!(votedUsers == vector<address>[user2], 14);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };

        // upvote -> downVote
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                false
            );

            let (
                postType,
                ipfsDoc,
                postTime,
                author,
                rating,
                communityId,
                officialReply,
                bestReply,
                deletedReplyCount,
                isDeleted,
                tags,
                properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
            assert!(postTime == 0, 3);
            assert!(author == user1, 4);
            assert!(rating == i64Lib::neg_from(1), 5);
            assert!(communityId == 1, 6);
            assert!(officialReply == 0, 7);
            assert!(bestReply == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[1, 2], 11);
            assert!(properties == vector<u8>[], 12);
            assert!(historyVotes == vector<u8>[1], 13);
            assert!(votedUsers == vector<address>[user2], 14);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };

         // upvote after cancel downVote
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                false
            );
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                true
            );

            let (
                postType,
                ipfsDoc,
                postTime,
                author,
                rating,
                communityId,
                officialReply,
                bestReply,
                deletedReplyCount,
                isDeleted,
                tags,
                properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
            assert!(postTime == 0, 3);
            assert!(author == user1, 4);
            assert!(rating == i64Lib::from(1), 5);
            assert!(communityId == 1, 6);
            assert!(officialReply == 0, 7);
            assert!(bestReply == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[1, 2], 11);
            assert!(properties == vector<u8>[], 12);
            assert!(historyVotes == vector<u8>[3], 13);
            assert!(votedUsers == vector<address>[user2], 14);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };
    }

    #[test]
    fun test_downVote_post() {
        use sui::test_scenario;

        // let owner = @0xC0FFEE;
        let user1 = @0xA1;
        let user2 = @0xA2;

        let scenario = &mut test_scenario::begin(&user1);
        {
            // userLib::initUserCollection(test_scenario::ctx(scenario));
            communityLib::initCommunity(test_scenario::ctx(scenario));
            userLib::initUser(test_scenario::ctx(scenario));
            init(test_scenario::ctx(scenario));
        };

        
        // create expert post
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
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

            createPost(
                postCollection,
                communityCollection,
                user1,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                EXPERT_POST,
                vector<u64>[1, 2]
            );

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, community_wrapper);
        };
        
        // downVote Post
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                false
            );

            let (
                _postType,
                _ipfsDoc,
                _postTime,
                _author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(rating == i64Lib::neg_from(1), 5);
            assert!(historyVotes == vector<u8>[1], 13);
            assert!(votedUsers == vector<address>[user2], 14);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };

        // cancel downVote Post
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                false
            );

            let (
                _postType,
                _ipfsDoc,
                _postTime,
                _author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(rating == i64Lib::from(0), 5);
            assert!(historyVotes == vector<u8>[2], 13);
            assert!(votedUsers == vector<address>[user2], 14);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };

        // downVote after cancel downVote Post
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                false
            );

            let (
                _postType,
                _ipfsDoc,
                _postTime,
                _author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(rating == i64Lib::neg_from(1), 5);
            assert!(historyVotes == vector<u8>[1], 13);
            assert!(votedUsers == vector<address>[user2], 14);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };

        // downVote -> upvote
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                true
            );

            let (
                _postType,
                _ipfsDoc,
                _postTime,
                _author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(rating == i64Lib::from(1), 5);
            assert!(historyVotes == vector<u8>[3], 13);
            assert!(votedUsers == vector<address>[user2], 14);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };

        // downVote after cancel upvote
        test_scenario::next_tx(scenario, &user1);
        {
            let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
            let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                true
            );
            voteForumItem(
                postCollection,
                userCollection,
                user2,
                1,
                0,
                0,
                false
            );

            let (
                _postType,
                _ipfsDoc,
                _postTime,
                _author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = getPostData(postCollection, 1);

            assert!(rating == i64Lib::neg_from(1), 5);
            assert!(historyVotes == vector<u8>[1], 13);
            assert!(votedUsers == vector<address>[user2], 14);

            test_scenario::return_shared(scenario, post_wrapper);
            test_scenario::return_shared(scenario, user_wrapper);
        };
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
            else abort 31

        } else if (postType == COMMON_POST) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_COMMON_POST)
            else abort 31

        } else if (postType == TYTORIAL) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_TUTORIAL)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_TUTORIAL)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_TUTORIAL)
            else abort 31

        } else {
            abort 31
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
            else abort 32

        } else if (postType == COMMON_POST) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_ACCEPT_REPLY) i64Lib::from(ACCEPT_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_ACCEPTED_REPLY) i64Lib::from(ACCEPTED_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_FIRST_REPLY) i64Lib::from(FIRST_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_QUICK_REPLY) i64Lib::from(QUICK_COMMON_REPLY)
            else abort 32

        } else if (postType == TYTORIAL) {
            i64Lib::zero()

        } else {
            abort 32
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

module basics::postLib {    
    use sui::transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use basics::communityLib;
    use basics::commonLib;
    use basics::userLib;
    use basics::i64Lib;
    // use sui::dynamic_object_field as ofield;

    use sui::table::{Self, Table};
    // use sui::bag::{Self, Bag};

    /* errors */

    const E_INVALID_POST_TYPE: u64 = 31;

    const E_INVALID_RESOURCE_TYPE: u64 = 32;

    const E_ITEM_ID_CAN_NOT_BE_0: u64 = 40;

    const E_USER_CAN_NOT_PUBLISH_2_REPLIES_FOR_EXPERT_AND_COMMON_POSTS: u64 = 41;

    const E_NOT_ALLOWED_EDIT_NOT_AUTHOR: u64 = 42;

    const E_YOU_CAN_NOT_EDIT_THIS_REPLY_IT_IS_NOT_YOUR: u64 = 43;

    const E_YOU_CAN_NOT_EDIT_THIS_COMMENT_IT_IS_NOT_YOUR: u64 = 44;

    const E_YOU_CAN_NOT_DELETE_THE_BEST_REPLY: u64 = 45;

    const E_YOU_CAN_NOT_PUBLISH_REPLIES_IN_TUTORIAL_OR_DOCUMENTATION: u64 = 46;

    const E_USER_IS_FORBIDDEN_TO_REPLY_ON_REPLY_FOR_EXPERT_AND_COMMON_TYPE_OF_POST: u64 = 47;

    const E_YOU_CAN_NOT_PUBLISH_COMMENTS_IN_DOCUMENTATION: u64 = 48;

    const E_THIS_POST_TYPE_IS_ALREADY_SET: u64 = 49;        // deleted

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

    const E_ERROR_CHANGE_COMMUNITY_ID: u64 = 61;

    const E_ONLY_OWNER_BY_POST_CAN_CHANGE_STATUS_BEST_REPLY: u64 = 64;

    const E_WRONG_SIGNER: u64 = 64;

    const E_AT_LEAST_ONE_TAG_IS_REQUIRED: u64 = 86;

    // 98, 99 - getPeriodRating  ???

    const QUICK_REPLY_TIME_SECONDS: u64 = 900; // 6
    const DELETE_TIME: u64 = 604800;    //7 days
    // const DEFAULT_COMMUNITY: ID = object::id_from_address(@0x0);

    // TODO: add enum PostType
    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;
    const DOCUMENTATION: u8 = 3;

    const DIRECTION_DOWNVOTE: u8 = 4;
    const DIRECTION_CANCEL_DOWNVOTE: u8 = 0;
    const DIRECTION_UPVOTE: u8 = 3;
    const DIRECTION_CANCEL_UPVOTE: u8 = 1;

    // TODO: add enum TypeContent
    const TYPE_CONTENT_POST: u8 = 0;
    const TYPE_CONTENT_REPLY: u8 = 1;
    const TYPE_CONTENT_COMMENT: u8 = 2;

    struct Post has key {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,
    }

    // add postId
    struct PostMetaData has key {       // shared
        id: UID,
        postType: u8,
        postTime: u64,
        author: ID,
        rating: i64Lib::I64,
        communityId: ID,

        officialReply: u64,     // new transfer ID || u64
        bestReply: u64,         // new transfer ID || u64
        deletedReplyCount: u64,
        isDeleted: bool,

        tags: vector<u64>,
        replies: Table<u64, ReplyMetaData>,
        comments: Table<u64, CommentMetaData>,
        properties: vector<u8>,

        historyVotes: vector<u8>,                 // downVote = 1, NONE = 2, upVote = 3
        voteUsers: vector<ID>
    }

    struct Reply has key {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,
    }

    // add replyId
    struct ReplyMetaData has key, store {
        id: UID,
        postTime: u64,
        author: ID,
        rating: i64Lib::I64,
        parentReplyId: u64,

        isFirstReply: bool,
        isQuickReply: bool,
        isDeleted: bool,

        comments: Table<u64, CommentMetaData>,
        properties: vector<u8>,
        historyVotes: vector<u8>,                 // to u128?   // 1 - negative, 2 - positive
        voteUsers: vector<ID>
    }

    struct Comment has key {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,

    }

    // commentId
    struct CommentMetaData has key, store {
        id: UID,
        postTime: u64,
        author: ID,
        rating: i64Lib::I64,

        isDeleted: bool,
        properties: vector<u8>,
        historyVotes: vector<u8>,                 // to u128?   // 1 - negative, 2 - positive
        voteUsers: vector<ID>
    }

    struct UserRatingChange {
        user: userLib::User,
        userCommunityRating: userLib::UserCommunityRating,
        rating: i64Lib::I64
    }

    public entry fun createPost(
        userCollection: &userLib::UserCollection,
        user: &mut userLib::User,
        community: &communityLib::Community, // new transfer community &mut
        ipfsHash: vector<u8>, 
        postType: u8,
        tags: vector<u64>,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let userAddr = tx_context::sender(ctx);     // del
        let userCommunityRating = userLib::getUserCommunityRating(userCollection, object::id(user));
        
        // checkSigner(user, userCommunityRating, userAddr);
        communityLib::onlyNotFrezenCommunity(community);
        communityLib::checkTags(community, tags);
        let communityId = object::id(community);
        userLib::checkActionRole(
            user,
            userCommunityRating,
            userId,
            userId,
            communityId,
            userLib::get_action_publication_post(),
            /*true*/
        );

        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());

        let postTags = vector::empty<u64>();
        if (postType != DOCUMENTATION) {
            assert!(vector::length(&mut tags) > 0, E_AT_LEAST_ONE_TAG_IS_REQUIRED);
            postTags = tags;
        };

        transfer::share_object(
            PostMetaData {
                id: object::new(ctx),
                postType: postType,
                postTime: commonLib::getTimestamp(),
                author: userId,
                rating: i64Lib::zero(),
                communityId: communityId,
                officialReply: 0,
                bestReply: 0,
                deletedReplyCount: 0,
                isDeleted: false,
                tags: postTags,
                replies: table::new(ctx),
                comments: table::new(ctx),
                properties: vector::empty<u8>(),
                historyVotes: vector::empty<u8>(),
                voteUsers: vector::empty<ID>(),
            }
        );

        transfer::transfer(
            Post {
                id: object::new(ctx),
                ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            },
            userAddr
        );

        // TODO: add emit PostCreated(userAddr, communityId, self.postCount);
    }

    public entry fun createReply(
        userCollection: &mut userLib::UserCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyId: u64,
        ipfsHash: vector<u8>,
        isOfficialReply: bool,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let userAddr = tx_context::sender(ctx);     // del
        // checkSigner(user, userCommunityRating, userAddr);
        let userCommunityRating = userLib::getMutableUserCommunityRating(userCollection, userId);

        assert!(postMetaData.postType != TUTORIAL && postMetaData.postType != DOCUMENTATION, E_YOU_CAN_NOT_PUBLISH_REPLIES_IN_TUTORIAL_OR_DOCUMENTATION);
        assert!(parentReplyId == 0, E_USER_IS_FORBIDDEN_TO_REPLY_ON_REPLY_FOR_EXPERT_AND_COMMON_TYPE_OF_POST);
        let communityId = postMetaData.communityId;
        userLib::checkActionRole(
            user,
            userCommunityRating,
            userId,
            postMetaData.author,
            communityId,
            userLib::get_action_publication_reply(),
            /*true*/
        );
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());

        let countReplies = table::length(&postMetaData.replies);
        if (postMetaData.postType == EXPERT_POST || postMetaData.postType == COMMON_POST) {
            let replyId = 0;
            while (replyId < countReplies) {
                let replyContainer = getReplyMetaData(postMetaData, replyId);
                assert!(
                    userId != replyContainer.author || replyContainer.isDeleted,
                    E_USER_CAN_NOT_PUBLISH_2_REPLIES_FOR_EXPERT_AND_COMMON_POSTS
                );
                replyId = replyId + 1;
            };
        };

        let replyUID = object::new(ctx);
        let isFirstReply = false;
        let isQuickReply = false;
        let timestamp: u64 = commonLib::getTimestamp();
        if (parentReplyId == 0) {
            if (isOfficialReply) {
                postMetaData.officialReply = countReplies + 1;
            };

            if (postMetaData.postType != TUTORIAL && postMetaData.author != userId) {
                let changeUserRating = i64Lib::zero();
                if (getActiveReplyCount(postMetaData) == 0) {
                    isFirstReply = true;
                    changeUserRating = i64Lib::add(&changeUserRating, &getUserRatingChangeForReplyAction(postMetaData.postType, RESOURCE_ACTION_FIRST_REPLY));
                };
                if (timestamp - postMetaData.postTime < QUICK_REPLY_TIME_SECONDS) {
                    isQuickReply = true;
                    changeUserRating = i64Lib::add(&changeUserRating, &getUserRatingChangeForReplyAction(postMetaData.postType, RESOURCE_ACTION_QUICK_REPLY));
                };
                userLib::updateRating(
                    userCommunityRating,
                    periodRewardContainer,
                    userId,
                    changeUserRating,
                    communityId,
                    ctx
                );
            };
        } else {
            getReplyMetaDataSafe(postMetaData, parentReplyId);  // checking parentReplyId is exist
        };

        let reply = ReplyMetaData {
            id: replyUID,
            postTime: timestamp,
            author: userId,
            rating: i64Lib::zero(),
            parentReplyId: parentReplyId,
              
            isFirstReply: isFirstReply,
            isQuickReply: isQuickReply,
            isDeleted: false,

            comments: table::new(ctx),
            properties: vector::empty<u8>(),
            historyVotes: vector::empty<u8>(),
            voteUsers: vector::empty<ID>(),
        };
        table::add(&mut postMetaData.replies, countReplies + 1, reply);

        transfer::transfer(
            Reply {
                id: object::new(ctx),
                ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            },
            userAddr
        );

        // TODO: add emit ReplyCreated(userAddr, postId, parentReplyId, postContainer.info.replyCount);
    }

    public entry fun createComment(
        userCollection: &userLib::UserCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyId: u64,
        ipfsHash: vector<u8>,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let userAddr = tx_context::sender(ctx);     // del
        let userCommunityRating = userLib::getUserCommunityRating(userCollection, userId);
        // checkSigner(user, userCommunityRating, userAddr);
        assert!(postMetaData.postType != DOCUMENTATION, E_YOU_CAN_NOT_PUBLISH_COMMENTS_IN_DOCUMENTATION);
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        userLib::checkActionRole(
            user,
            userCommunityRating,
            userId,
            postMetaData.author,
            postMetaData.communityId,
            userLib::get_action_publication_comment(),
            /*true*/
        );

        if (parentReplyId == 0) {
            let countComments = table::length(&postMetaData.comments);
            let comment = CommentMetaData {
                id: object::new(ctx),
                postTime: commonLib::getTimestamp(),
                author: userId,
                rating: i64Lib::zero(),
                isDeleted: false,

                properties: vector::empty<u8>(),
                historyVotes: vector::empty<u8>(),
                voteUsers: vector::empty<ID>(),
            };
            table::add(&mut postMetaData.comments, countComments, comment);
        } else {
            let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, parentReplyId);

            let countComments = table::length(&replyMetaData.comments);
            let comment = CommentMetaData {
                id: object::new(ctx),
                postTime: commonLib::getTimestamp(),
                author: userId,
                rating: i64Lib::zero(),
                isDeleted: false,

                properties: vector::empty<u8>(),
                historyVotes: vector::empty<u8>(),
                voteUsers: vector::empty<ID>(),
            };
            table::add(&mut replyMetaData.comments, countComments, comment);
        };

        transfer::transfer(
            Comment {
                id: object::new(ctx),
                ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            },
            userAddr
        );

        // TODO: add emit CommentCreated(userAddr, postId, parentReplyId, commentId);
    }

    public entry fun editPost(
        userCollection: &userLib::UserCollection,
        user: &mut userLib::User,
        post: &mut Post,
        postMetaData: &mut PostMetaData,
        community: &communityLib::Community,
        ipfsHash: vector<u8>, 
        tags: vector<u64>,
        newCommunityId: ID,
        _newPostType: u8,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let _userAddr = tx_context::sender(ctx);             // del
        let userCommunityRating = userLib::getUserCommunityRating(userCollection, userId);
        // checkSigner(user, userCommunityRating, userAddr);
        // changePostType(postMetaData, newPostType);                                  // TODO: add tests
        // changePostCommunity(postMetaData, community, newCommunityId);               // TODO: add tests

        /*if(userId == postMetaData.author) {*/
            assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());       // todo: test
            if(commonLib::getIpfsHash(post.ipfsDoc) != ipfsHash)
                post.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        // } else {     // recomment
        //     assert!(commonLib::getIpfsHash(post.ipfsDoc) == ipfsHash, E_NOT_ALLOWED_EDIT_NOT_AUTHOR);       // todo: test
        //     if (newCommunityId != postMetaData.communityId /*&& newCommunityId != DEFAULT_COMMUNITY *//*&& !self.peeranhaUser.isProtocolAdmin(userAddr)*/) // todo new transfer 
        //         abort E_ERROR_CHANGE_COMMUNITY_ID
        // };
        userLib::checkActionRole(
            user,
            userCommunityRating,
            userId,
            postMetaData.author,
            postMetaData.communityId,
            if(userId == postMetaData.author) userLib::get_action_edit_item() else userLib::get_action_none(),
            /*false*/
        );

        if(vector::length(&tags) > 0) {
            communityLib::checkTags(community, postMetaData.tags);
            postMetaData.tags = tags;
        };

        // TODO: add emit PostEdited(userAddr, postId);
    }

    public entry fun editReply(     // isDeleted?
        userCollection: &userLib::UserCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        reply: &mut Reply,      // reply match with replyId?
        replyId: u64,
        ipfsHash: vector<u8>, 
        isOfficialReply: bool,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let _userAddr = tx_context::sender(ctx);             // del
        let replyMetaData = getReplyMetaDataSafe(postMetaData, replyId);
        let userCommunityRating = userLib::getUserCommunityRating(userCollection, userId);
        
        // checkSigner(user, userCommunityRating, userAddr);
        userLib::checkActionRole(
            user,
            userCommunityRating,
            userId,
            replyMetaData.author,
            postMetaData.communityId,
            userLib::get_action_edit_item(),
            /*false*/
        );
        
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        assert!(userId == replyMetaData.author, E_YOU_CAN_NOT_EDIT_THIS_REPLY_IT_IS_NOT_YOUR);

        if (commonLib::getIpfsHash(reply.ipfsDoc) != ipfsHash)
            reply.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        
        if (isOfficialReply) {
            postMetaData.officialReply = replyId;
        } else if (postMetaData.officialReply == replyId)
            postMetaData.officialReply = 0;

        // TODO: add emit ReplyEdited(userAddr, postId, replyId);
    }

    public entry fun editComment(
        userCollection: &userLib::UserCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        comment: &mut Comment,
        parentReplyId: u64,
        commentId: u64,
        ipfsHash: vector<u8>,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let _userAddr = tx_context::sender(ctx);             // del
        // checkSigner(user, userCommunityRating, userAddr);
        let commentMetaData = getCommentContainerSafe(postMetaData, parentReplyId, commentId);
        let userCommunityRating = userLib::getUserCommunityRating(userCollection, userId);

        userLib::checkActionRole(
            user,
            userCommunityRating,
            userId,
            commentMetaData.author,
            postMetaData.communityId,
            userLib::get_action_edit_item(),
            /*false*/
        );
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        assert!(userId == commentMetaData.author, E_YOU_CAN_NOT_EDIT_THIS_COMMENT_IT_IS_NOT_YOUR);

        if (commonLib::getIpfsHash(comment.ipfsDoc) != ipfsHash)
            comment.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        // TODO: add emit CommentEdited(userAddr, postId, parentReplyId, commentId);
    }

    // &mut
    public entry fun deletePost( // updateRating will make only 1 action
        userCollection: &mut userLib::UserCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        ctx: &mut TxContext
    ) {
        // let userAddr = tx_context::sender(ctx);
        // checkSigner(user, userCommunityRating, userAddr);

        let communityId = postMetaData.communityId;
        let postAuthor = postMetaData.author;
        let bestReplyId = postMetaData.bestReply;
        let userId = object::id(user);
        let userCommunityRating = userLib::getMutableUserCommunityRating(userCollection, userId);
        userLib::checkActionRole(
            user,
            userCommunityRating,
            userId,
            postAuthor,
            communityId,
            userLib::get_action_delete_item(),
            /*false*/
        );

        let postType = postMetaData.postType;
        if (postType != DOCUMENTATION) {
            let time: u64 = commonLib::getTimestamp();
            if (time - postMetaData.postTime < DELETE_TIME || userId == postAuthor) {
                let typeRating: StructRating = getTypesRating(postType);
                let (positive, negative) = getHistoryInformations(postMetaData.historyVotes, postMetaData.voteUsers);

                let changeUserRating: i64Lib::I64 = i64Lib::add(&i64Lib::mul(&typeRating.upvotedPost, &i64Lib::from(positive)), &i64Lib::mul(&typeRating.downvotedPost, &i64Lib::from(negative)));
                if (i64Lib::compare(&changeUserRating, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                    userLib::updateRating(
                        userCommunityRating,
                        periodRewardContainer,
                        userId,
                        i64Lib::mul(&changeUserRating, &i64Lib::neg_from(1)),   // *= -1
                        communityId,
                        ctx
                    );
                };
            };
            if (bestReplyId != 0) {
                userLib::updateRating(
                    userCommunityRating,
                    periodRewardContainer,
                    userId,
                    i64Lib::mul(&getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPTED_REPLY), &i64Lib::neg_from(1)),   // *= -1
                    communityId,
                    ctx
                );
            };

            userLib::updateRating(
                userCommunityRating,
                periodRewardContainer,
                userId,
                if(userId == postAuthor)
                    i64Lib::neg_from(DELETE_OWN_POST) else
                    i64Lib::neg_from(MODERATOR_DELETE_POST),
                communityId,
                ctx
            );

            if (time - postMetaData.postTime < DELETE_TIME || userId == postAuthor) {
                let replyCount = table::length(&postMetaData.replies);
                let replyId = 0;

                while (replyId < replyCount) {
                    let replyMetaData = getReplyMetaData(postMetaData, replyId);
                    let replyAuthorCommunityRating = userLib::getMutableUserCommunityRating(userCollection, replyMetaData.author);

                    deductReplyRating(
                        replyAuthorCommunityRating,
                        periodRewardContainer,
                        replyMetaData,
                        postType,
                        bestReplyId == replyId,
                        communityId,
                        ctx
                    );
                    replyId = replyId + 1;
                }
            };
        };

        postMetaData.isDeleted = true;
        // TODO: add emit PostDeleted(userAddr, postId);
    }

    public entry fun deleteReply(
        userCollection: &mut userLib::UserCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        replyId: u64,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let communityId = postMetaData.communityId;
        let userCommunityRating = userLib::getMutableUserCommunityRating(userCollection, object::id(user));
        
        postMetaData.deletedReplyCount = postMetaData.deletedReplyCount + 1;
        if (postMetaData.bestReply == replyId)
            postMetaData.bestReply = 0;

        if (postMetaData.officialReply == replyId)
            postMetaData.officialReply = 0;
        let postType = postMetaData.postType;
        let bestReply = postMetaData.bestReply;
        
        let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, replyId);
        // checkSigner(user, userCommunityRating, userAddr);
        userLib::checkActionRole(
            user,
            userCommunityRating,
            userId,
            replyMetaData.author,
            communityId,
            userLib::get_action_delete_item(),
            /*false*/
        );
        
        assert!(userId != replyMetaData.author || bestReply != replyId, E_YOU_CAN_NOT_DELETE_THE_BEST_REPLY);
        
        let time: u64 = commonLib::getTimestamp();
        let isDeductReplyRating = time - replyMetaData.postTime < DELETE_TIME || userId == replyMetaData.author;
        userLib::updateRating(
            userCommunityRating,
            periodRewardContainer,
            object::id(user),
            if(userId == replyMetaData.author) 
                i64Lib::neg_from(DELETE_OWN_REPLY) else 
                i64Lib::neg_from(MODERATOR_DELETE_REPLY),
            communityId,
            ctx
        );
        
        replyMetaData.isDeleted = true;
        let parentReplyId = replyMetaData.parentReplyId;
        if (isDeductReplyRating) {
            deductReplyRating(
                userCommunityRating,
                periodRewardContainer,
                replyMetaData,
                postType,
                parentReplyId == 0 && bestReply == replyId,
                communityId,
                ctx
            );
        };

        // TODO: add emit ReplyDeleted(userAddr, postId, replyId);
    }


    fun deductReplyRating(
        userCommunityRating: &mut userLib::UserCommunityRating,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        replyMetaData: &ReplyMetaData,
        postType: u8,
        isBestReply: bool,
        communityId: ID,
        ctx: &mut TxContext
    ) {
        // TODO: add
        // if (CommonLib.isEmptyIpfs(replyContainer.info.ipfsDoc.hash) || replyContainer.info.isDeleted)
        //     return;

        let changeReplyAuthorRating: i64Lib::I64 = i64Lib::zero();
        if (i64Lib::compare(&replyMetaData.rating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&replyMetaData.rating, &i64Lib::zero()) == i64Lib::getEual()) {  //reply.rating >= 0
            if (replyMetaData.isFirstReply) {// -=? in solidity "+= -"
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_FIRST_REPLY));
            };
            if (replyMetaData.isQuickReply) {// -=? in solidity "+= -"
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_QUICK_REPLY));
            };
            if (isBestReply && postType != TUTORIAL) {// -=? in solidity "+= -"
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPT_REPLY));
            };
        };

        // change user rating considering reply rating
        let typeRating: StructRating = getTypesRating(postType);
        let (positive, negative) = getHistoryInformations(replyMetaData.historyVotes, replyMetaData.voteUsers);
        
        // typeRating.upvotedReply * positive + typeRating.downvotedReply * negative;
        let changeUserRating: i64Lib::I64 = i64Lib::add(&i64Lib::mul(&typeRating.upvotedReply, &i64Lib::from(positive)), &i64Lib::mul(&typeRating.downvotedReply, &i64Lib::from(negative)));
        
        if (i64Lib::compare(&changeUserRating, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
            changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &changeUserRating); // -=?
        };

        if (i64Lib::compare(&changeReplyAuthorRating, &i64Lib::zero()) != i64Lib::getEual()) {
            userLib::updateRating(
                userCommunityRating,
                periodRewardContainer,
                replyMetaData.author,
                changeReplyAuthorRating,
                communityId,
                ctx
            );
        };
    }

    public entry fun deleteComment(
        userCollection: &mut userLib::UserCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyId: u64,
        commentId: u64,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let _userAddr = tx_context::sender(ctx);     // del
        let communityId = postMetaData.communityId;
        // checkSigner(user, userCommunityRating, userAddr);
        let commentMetaData = getMutableCommentContainerSafe(postMetaData, parentReplyId, commentId);
        let userCommunityRating = userLib::getMutableUserCommunityRating(userCollection, object::id(user));
        
        userLib::checkActionRole(
            user,
            userCommunityRating,
            userId,
            commentMetaData.author,
            communityId,
            userLib::get_action_delete_item(),
            /*false*/
        );

        if (userId != commentMetaData.author) {
            userLib::updateRating(
                userCommunityRating,
                periodRewardContainer,
                object::id(user),
                i64Lib::neg_from(MODERATOR_DELETE_COMMENT),
                communityId,
                ctx
            );
        };

        commentMetaData.isDeleted = true;
        // TODO: add emit CommentDeleted(userAddr, postId, parentReplyId, commentId);
    }

    public entry fun changeStatusBestReply(
        userCollection: &mut userLib::UserCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        postAuthor: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        newBestReplyId: u64,
        oldBestReplyId: u64,
        ctx: &mut TxContext
    ) {
        let newBestReplyMetaData = getReplyMetaDataSafe(postMetaData, newBestReplyId);
        let oldBestReplyMetaData = getReplyMetaDataSafe(postMetaData, oldBestReplyId);

        let communityId = postMetaData.communityId;
        assert!(postMetaData.author == postMetaData.author, E_ONLY_OWNER_BY_POST_CAN_CHANGE_STATUS_BEST_REPLY);

        if (postMetaData.bestReply == newBestReplyId) {
            updateRatingForBestReply(
                userCollection,
                periodRewardContainer,
                postMetaData.author,
                oldBestReplyMetaData.author,
                postMetaData.postType,
                false,
                communityId,
                ctx
            );
            postMetaData.bestReply = 0;
        } else {
            if (postMetaData.bestReply != 0) {
                updateRatingForBestReply(
                    userCollection,
                    periodRewardContainer,
                    postMetaData.author,
                    oldBestReplyMetaData.author,
                    postMetaData.postType,
                    false,
                    communityId,
                    ctx
                );
            };

            updateRatingForBestReply(
                userCollection,
                periodRewardContainer,
                postMetaData.author,
                newBestReplyMetaData.author,
                postMetaData.postType,
                true,
                communityId,
                ctx
            );
            postMetaData.bestReply = newBestReplyId;
        };
        let postAuthorId = object::id(postAuthor);
        let postAuthorCommunityRating = userLib::getUserCommunityRating(userCollection, postMetaData.author);
        userLib::checkActionRole(
            postAuthor,
            postAuthorCommunityRating,
            postAuthorId,
            postMetaData.author,
            communityId,
            userLib::get_action_best_reply(),
            //false
        );

        // emit StatusBestReplyChanged(userAddr, postId, postContainer.info.bestReply);
    }

    
    fun updateRatingForBestReply(
        userCollection: &mut userLib::UserCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        postAuthorAddress: ID,
        replyAuthorAddress: ID,
        postType: u8,
        isMark: bool,
        communityId: ID,
        ctx: &mut TxContext
    ) {
        if (postAuthorAddress != replyAuthorAddress) {
            let postAuthorCommunityRating = userLib::getMutableUserCommunityRating(userCollection, postAuthorAddress);
            userLib::updateRating(
                postAuthorCommunityRating,
                periodRewardContainer,
                postAuthorAddress,
                if (isMark)
                    getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPTED_REPLY) else
                    i64Lib::mul(&getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPTED_REPLY), &i64Lib::neg_from(1)),
                communityId,
                ctx
            );

            let replyAuthorCommunityRating = userLib::getMutableUserCommunityRating(userCollection, replyAuthorAddress);
            userLib::updateRating(
                replyAuthorCommunityRating,
                periodRewardContainer,
                replyAuthorAddress,
                if (isMark)
                    getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPT_REPLY) else
                    i64Lib::mul(&getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPT_REPLY), &i64Lib::neg_from(1)),
                communityId,
                ctx
            );
        }
    }

    public entry fun votePost(
        userCollection: &mut userLib::UserCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        voteUser: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        isUpvote: bool,
        ctx: &mut TxContext
    ): u8 {
        // let voteUserAddress = tx_context::sender(ctx);
        // checkSigner(voteUser, voteUserCommunityRating, voteUserAddress);
        // checkSigner(votedUser, votedUserCommunityRating, postMetaData.author);
        let postType = postMetaData.postType;
        let voteUserId = object::id(voteUser);
        assert!(postType != DOCUMENTATION, E_YOU_CAN_NOT_VOTE_TO_DOCUMENTATION);
        assert!(voteUserId != postMetaData.author, E_ERROR_VOTE_POST);
        
        let (ratingChange, isCancel) = getForumItemRatingChange(voteUserId, &mut postMetaData.historyVotes, isUpvote, &mut postMetaData.voteUsers);
        let voteUserCommunityRating = userLib::getUserCommunityRating(userCollection, voteUserId);
        userLib::checkActionRole(
            voteUser,
            voteUserCommunityRating,
            voteUserId,
            postMetaData.author,
            postMetaData.communityId,
            if(isCancel) 
                userLib::get_action_cancel_vote() else 
                    if(i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) 
                        userLib::get_action_upvote_post() else 
                        userLib::get_action_downvote_post(),
            /*false*/
        );

        vote(
            userCollection,
            periodRewardContainer,
            voteUserId,
            postMetaData.author,
            postType,
            isUpvote,
            ratingChange,
            TYPE_CONTENT_POST,
            postMetaData.communityId,
            ctx
        );
        postMetaData.rating = i64Lib::add(&postMetaData.rating, &ratingChange);

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
        // transfer add ForumItemVoted delete return value
    }

    // public entry fun voteReply(
    //     postMetaData: &PostMetaData,
    //     replyMetaData: &mut ReplyMetaData,
    //     voteUser: &mut userLib::User,
    //     voteUserCommunityRating: &mut userLib::UserCommunityRating,
    //     votedUser: &userLib::User,
    //     votedUserCommunityRating: &mut userLib::UserCommunityRating,
    //     isUpvote: bool,
    //     ctx: &mut TxContext
    // ): u8 {
    //     let postType = postMetaData.postType;
    //     let voteUserAddress = tx_context::sender(ctx);
    //     let communityId = postMetaData.communityId;
    //     checkSigner(voteUser, voteUserCommunityRating, voteUserAddress);
    //     checkSigner(votedUser, votedUserCommunityRating, replyMetaData.author);
    //     assert!(voteUserAddress != replyMetaData.author, E_ERROR_VOTE_REPLY);

    //     let (ratingChange, isCancel) = getForumItemRatingChange(voteUserAddress, &mut replyMetaData.historyVotes, isUpvote, &mut replyMetaData.voteUsers);
    //     // ed / e && other argument
    //     userLib::checkActionRole(
    //         voteUser,
    //         voteUserCommunityRating,
    //         voteUserAddress,
    //         replyMetaData.author,
    //         communityId,
    //         if(isCancel) 
    //             userLib::get_action_cancel_vote() else 
    //                 if(i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) 
    //                     userLib::get_action_upvote_reply() else 
    //                     userLib::get_action_downvote_reply(),
    //         /*false*/
    //     );

    //     let oldRating: i64Lib::I64 = replyMetaData.rating;
    //     replyMetaData.rating = i64Lib::add(&replyMetaData.rating, &ratingChange);
    //     let newRating: i64Lib::I64 = replyMetaData.rating;

    //     let changeReplyAuthorRating: i64Lib::I64 = i64Lib::zero();
    //     if (replyMetaData.isFirstReply) {  // oldRating < 0 && newRating >= 0
    //         if (i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getLessThan() && (i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getEual())) {
    //             changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_FIRST_REPLY));
    //         } else if ((i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getEual()) && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getLessThan()) { // (oldRating >= 0 && newRating < 0)
    //             changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_FIRST_REPLY));
    //         };
    //     };

    //     if (replyMetaData.isQuickReply) { //oldRating < 0 && newRating >= 0
    //         if (i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getLessThan() && (i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getEual())) {
    //             changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_QUICK_REPLY));
    //         } else if ((i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getEual()) && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getLessThan()) { // oldRating >= 0 && newRating < 0
    //             changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_QUICK_REPLY));
    //         };
    //     };

    //     userLib::updateRatingNotFull(
    //         replyMetaData.author,
    //         votedUserCommunityRating,
    //         changeReplyAuthorRating,
    //         communityId
    //     );
        
    //     vote(votedUser, votedUserCommunityRating, voteUser, voteUserCommunityRating, postType, isUpvote, ratingChange, TYPE_CONTENT_REPLY, postMetaData.communityId);
        
    //     if (isCancel) {
    //         if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
    //             DIRECTION_CANCEL_DOWNVOTE
    //         } else {
    //             DIRECTION_CANCEL_UPVOTE
    //         }
    //     } else {
    //         if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
    //             DIRECTION_UPVOTE
    //         } else {
    //             DIRECTION_DOWNVOTE
    //         }
    //     }
    //     // transfer add ForumItemVoted delete return value
    // }

    // public entry fun voteComment(
    //     postMetaData: &PostMetaData,
    //     commentMetaData: &mut CommentMetaData,
    //     voteUser: &mut userLib::User,
    //     voteUserCommunityRating: &userLib::UserCommunityRating,
    //     isUpvote: bool,
    //     ctx: &mut TxContext
    // ): u8 {
    //     let voteUserAddress = tx_context::sender(ctx);
    //     checkSigner(voteUser, voteUserCommunityRating, voteUserAddress);
    //     assert!(voteUserAddress != commentMetaData.author, E_ERROR_VOTE_COMMENT);
        
    //     let (ratingChange, isCancel) = getForumItemRatingChange(voteUserAddress, &mut commentMetaData.historyVotes, isUpvote, &mut commentMetaData.voteUsers);
    //     // ed / e && other argument
    //     userLib::checkActionRole(
    //         voteUser,
    //         voteUserCommunityRating,
    //         voteUserAddress,
    //         commentMetaData.author,
    //         postMetaData.communityId,
    //         if(isCancel) 
    //             userLib::get_action_cancel_vote() else  
    //             userLib::get_action_vote_comment(),
    //         /*false*/
    //     );
        
    //     commentMetaData.rating = i64Lib::add(&commentMetaData.rating, &ratingChange);

    //     if (isCancel) {
    //         if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
    //             DIRECTION_CANCEL_DOWNVOTE
    //         } else {
    //             DIRECTION_CANCEL_UPVOTE
    //         }
    //     } else {
    //         if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
    //             DIRECTION_UPVOTE
    //         } else {
    //             DIRECTION_DOWNVOTE
    //         }
    //     }
    //     // transfer add ForumItemVoted delete return value
    // }

    fun vote(
        userCollection: &mut userLib::UserCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        voteUserId: ID,
        votedUserId: ID,
        postType: u8,
        isUpvote: bool,
        ratingChanged: i64Lib::I64,
        typeContent: u8,
        communityId: ID,
        ctx: &mut TxContext
    ) {
        // TODO: add why warning - Unused assignment or binding for local '_authorRating'. Consider removing, replacing with '_', or prefixing with '_'
        let voteUserRating = i64Lib::zero();
        let _authorRating = i64Lib::zero();

        if (isUpvote) {
            _authorRating = getUserRatingChange(postType, RESOURCE_ACTION_UPVOTED, typeContent);

            if (i64Lib::compare(&ratingChanged, &i64Lib::from(2)) == i64Lib::getEual()) {
                _authorRating = i64Lib::add(&_authorRating, &i64Lib::mul(&getUserRatingChange(postType, RESOURCE_ACTION_DOWNVOTED, typeContent), &i64Lib::neg_from(1)));
                voteUserRating = i64Lib::mul(&getUserRatingChange(postType, RESOURCE_ACTION_DOWNVOTE, typeContent), &i64Lib::neg_from(1)); 
            };

            if (i64Lib::compare(&ratingChanged, &i64Lib::zero()) == i64Lib::getLessThan()) {
                _authorRating = i64Lib::mul(&_authorRating, &i64Lib::neg_from(1));
                voteUserRating = i64Lib::mul(&voteUserRating, &i64Lib::neg_from(1));
            };
        } else {
            _authorRating = getUserRatingChange(postType, RESOURCE_ACTION_DOWNVOTED, typeContent);
            voteUserRating = getUserRatingChange(postType, RESOURCE_ACTION_DOWNVOTE, typeContent);

            if (i64Lib::compare(&ratingChanged, &i64Lib::neg_from(2)) == i64Lib::getEual()) {
                _authorRating = i64Lib::add(&_authorRating, &i64Lib::mul(&getUserRatingChange(postType, RESOURCE_ACTION_UPVOTED, typeContent), &i64Lib::neg_from(1)));
            };

            if (i64Lib::compare(&ratingChanged, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                _authorRating = i64Lib::mul(&_authorRating, &i64Lib::neg_from(1));
                voteUserRating = i64Lib::mul(&voteUserRating, &i64Lib::neg_from(2));  
            };
        };

        let voteUserCommunityRating = userLib::getMutableUserCommunityRating(userCollection, voteUserId);
        userLib::updateRating(
            voteUserCommunityRating,
            periodRewardContainer,
            voteUserId,
            voteUserRating,
            communityId,
            ctx
        );

        let votedUserCommunityRating = userLib::getMutableUserCommunityRating(userCollection, votedUserId);
        userLib::updateRating(
            votedUserCommunityRating,
            periodRewardContainer,
            votedUserId,
            _authorRating,
            communityId,
            ctx
        );
    }

    /* transfer add      
    fun changePostType(
        postMetaData: &mut PostMetaData,
        newPostType: u8
    ) {
        if (postMetaData.postType == newPostType) return;

        let oldPostType = postMetaData.postType;
        assert!(newPostType != TUTORIAL || getActiveReplyCount(postMetaData) == 0, E_ERROR_POST_TYPE);

        let oldTypeRating: StructRating = getTypesRating(oldPostType);
        let newTypeRating: StructRating = getTypesRating(newPostType);

        let (positive, negative) = getHistoryInformations(postMetaData.historyVotes, postMetaData.voteUsers);

        let positiveRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.upvotedPost, &oldTypeRating.upvotedPost), &i64Lib::from(positive));
        let negativeRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.downvotedPost, &oldTypeRating.downvotedPost), &i64Lib::from(negative));
        let changePostAuthorRating = i64Lib::add(&positiveRating, &negativeRating);

        let bestReplyId = postMetaData.bestReply;
        let replyId = 1;                                // transfer name
        while(replyId <= table::length(&postMetaData.replies)) {
            let replyMetaData = table::borrow(&postMetaData.replies, replyId - 1);
            if (replyMetaData.isDeleted) {
                replyId = replyId + 1;
                continue
            };
            let (positive, negative) = getHistoryInformations(replyMetaData.historyVotes, replyMetaData.voteUsers);

            positiveRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.upvotedReply, &oldTypeRating.upvotedReply), &i64Lib::from(positive));
            negativeRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.downvotedReply, &oldTypeRating.downvotedReply), &i64Lib::from(negative));
            let _changeReplyAuthorRating = i64Lib::add(&positiveRating, &negativeRating);

            if (i64Lib::compare(&replyMetaData.rating, &i64Lib::zero()) == i64Lib::getGreaterThan() 
                || i64Lib::compare(&replyMetaData.rating, &i64Lib::zero()) == i64Lib::getEual()) {
                if (replyMetaData.isFirstReply) {
                    _changeReplyAuthorRating = i64Lib::add(&_changeReplyAuthorRating, &i64Lib::sub(&newTypeRating.firstReply, &oldTypeRating.firstReply));
                };
                if (replyMetaData.isQuickReply) {
                    _changeReplyAuthorRating = i64Lib::add(&_changeReplyAuthorRating, &i64Lib::sub(&newTypeRating.quickReply, &oldTypeRating.quickReply));
                };
            };
            if (bestReplyId == object::id(replyMetaData)) {
                _changeReplyAuthorRating = i64Lib::add(&_changeReplyAuthorRating, &i64Lib::sub(&newTypeRating.acceptReply, &oldTypeRating.acceptReply));
                changePostAuthorRating = i64Lib::add(&changePostAuthorRating, &i64Lib::sub(&newTypeRating.acceptedReply, &oldTypeRating.acceptedReply));
            };
            // TODO: add
            // self.peeranhaUser.updateUserRating(replyContainer.info.author, changeReplyAuthorRating, postContainer.info.communityId);
            
            // userLib::updateRatingNotFull(
            //     replyMetaData.author,
            //     userCommunityRating,
            //     changePostAuthorRating,
            //     postMetaData.communityId
            // );
            replyId = replyId + 1;
        };

        // self.peeranhaUser.updateUserRating(postContainer.info.author, changePostAuthorRating, postContainer.info.communityId);
        postMetaData.postType = newPostType;
        // TODO: add
        // emit ChangePostType(userAddr, postId, newPostType);
    */

    /* transfer add 
    fun changePostCommunity(
        postMetaData: &mut PostMetaData,
        community: &communityLib::Community, // new transfer community &mut
        newCommunityId: ID
    ) {
        if (postMetaData.communityId == newCommunityId) return;

        communityLib::onlyNotFrezenCommunity(community);
        let _oldCommunityId: ID = postMetaData.communityId;
        let postType: u8 = postMetaData.postType;
        let typeRating: StructRating = getTypesRating(postType);

        let (positive, negative) = getHistoryInformations(postMetaData.historyVotes, postMetaData.voteUsers);

        let positiveRating = i64Lib::mul(&typeRating.upvotedPost, &i64Lib::from(positive));
        let negativeRating = i64Lib::mul(&typeRating.downvotedPost, &i64Lib::from(negative));
        let _changePostAuthorRating = i64Lib::add(&positiveRating, &negativeRating);

        let bestReplyId = postMetaData.bestReply;
        let replyId = 1;
        while(replyId <= table::length(&postMetaData.replies)) {
            // let reply = getReplyContainer(post, replyId);
            let reply = table::borrow(&postMetaData.replies, replyId - 1);
            if (reply.isDeleted) {
                replyId = replyId + 1;
                continue
            };
            (positive, negative) = getHistoryInformations(reply.historyVotes, reply.voteUsers);

            positiveRating = i64Lib::mul(&typeRating.upvotedReply, &i64Lib::from(positive));
            negativeRating = i64Lib::mul(&typeRating.downvotedReply, &i64Lib::from(negative));
            let changeReplyAuthorRating = i64Lib::add(&positiveRating, &negativeRating);
            if (i64Lib::compare(&reply.rating, &i64Lib::zero()) == i64Lib::getGreaterThan() 
                || i64Lib::compare(&reply.rating, &i64Lib::zero()) == i64Lib::getEual()) {
                if (reply.isFirstReply) {
                    changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &typeRating.firstReply);
                };
                if (reply.isQuickReply) {
                    changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &typeRating.quickReply);
                };
            };
            if (bestReplyId == object::id(reply.id)) {
                changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &typeRating.acceptReply);
                _changePostAuthorRating = i64Lib::add(&changeReplyAuthorRating, &typeRating.acceptedReply);
            };

            // todo
            // self.peeranhaUser.updateUserRating(replyContainer.info.author, -changeReplyAuthorRating, oldCommunityId);
            // self.peeranhaUser.updateUserRating(replyContainer.info.author, changeReplyAuthorRating, newCommunityId);
            replyId = replyId + 1;
        };

        //todo
        // self.peeranhaUser.updateUserRating(postContainer.info.author, -changePostAuthorRating, oldCommunityId);
        // self.peeranhaUser.updateUserRating(postContainer.info.author, changePostAuthorRating, newCommunityId);
        postMetaData.communityId = newCommunityId;
    }
    */

    public entry fun addUserRating(     // del
        userCollection: &mut userLib::UserCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        user: &mut userLib::User,
        community: &mut userLib::UserCollection,
        changeRating: u64,
        isPositive: bool,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let userCommunityRating = userLib::getMutableUserCommunityRating(userCollection, userId);

        userLib::updateRating(
            userCommunityRating,
            periodRewardContainer,
            userId,
            if(isPositive) i64Lib::from(changeRating) else i64Lib::neg_from(changeRating),
            object::id(community),
            ctx
        );
    }

    fun checkSigner(        // need?
        _user: &userLib::User,
        _userCommunityRating: &userLib::UserCommunityRating,
        _userAddress: address
    ) {
    //    assert!(
    //         userLib::getUserOwner(user) == userAddress &&
    //         userLib::getUserRatingId(user) == object::id(userCommunityRating),
    //         E_WRONG_USER_PARAMS_DELETE_POST
    //     ); 
    }

    fun getTypesRating(        //name?
        postType: u8
    ): StructRating {
        if (postType == EXPERT_POST) {
            getExpertRating()
        } else if (postType == COMMON_POST) {
            getCommonRating()
        } else if (postType == TUTORIAL) {
            getTutorialRating()
        } else {
            abort E_INVALID_POST_TYPE
        }
    }

    fun getHistoryInformations(        //name?
        historyVotes: vector<u8>,
        votedUsers: vector<ID>
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

    // public fun getPostContainer(postCollection: &mut PostCollection, postId: u64): &mut Post { // getPostContainer -> getPostContainerSafe in solidity to
    //     assert!(postId > 0, E_ITEM_ID_CAN_NOT_BE_0);
    //     assert!(vector::length(&postCollection.posts) >= postId, E_POST_NOT_EXIST);
    //     let post = vector::borrow_mut(&mut postCollection.posts, postId - 1);
    //     assert!(!post.isDeleted, E_POST_DELETED);
    //     post
    // }
    
    // public fun getMutablePost(postCollection: &mut PostCollection, postId: u64): &mut Post {
    //     assert!(postId > 0, E_ITEM_ID_CAN_NOT_BE_0);
    //     assert!(vector::length(&postCollection.posts) >= postId, E_POST_NOT_EXIST);
    //     let post = vector::borrow_mut(&mut postCollection.posts, postId - 1);
    //     assert!(!post.isDeleted, E_POST_DELETED);
    //     post
    // }

    public fun getMutableReplyMetaData(postMetaData: &mut PostMetaData, replyId: u64): &mut ReplyMetaData {
        assert!(replyId >= 0, E_ITEM_ID_CAN_NOT_BE_0);
        assert!(table::length(&postMetaData.replies) >= replyId, E_REPLY_NOT_EXIST);
        let replyMetaData = table::borrow_mut<u64, ReplyMetaData>(&mut postMetaData.replies, replyId);
        replyMetaData
    }

    public fun getMutableReplyMetaDataSafe(postMetaData: &mut PostMetaData, replyId: u64): &mut ReplyMetaData {
        let replyMetaData = getMutableReplyMetaData(postMetaData, replyId);
        assert!(!replyMetaData.isDeleted, E_REPLY_DELETED);
        replyMetaData
    }

    public fun getReplyMetaData(postMetaData: &PostMetaData, replyId: u64): &ReplyMetaData {
        assert!(replyId >= 0, E_ITEM_ID_CAN_NOT_BE_0);
        assert!(table::length(&postMetaData.replies) >= replyId, E_REPLY_NOT_EXIST);
        let replyMetaData = table::borrow<u64, ReplyMetaData>(&postMetaData.replies, replyId);
        replyMetaData
    }

    public fun getReplyMetaDataSafe(postMetaData: &PostMetaData, replyId: u64): &ReplyMetaData {
        let replyMetaData = getReplyMetaData(postMetaData, replyId);
        assert!(!replyMetaData.isDeleted, E_REPLY_DELETED);
        replyMetaData
    }

    public fun getMutableCommentMetaData(postMetaData: &mut PostMetaData, parentReplyId: u64, commentId: u64): &mut CommentMetaData {
        assert!(commentId > 0, E_ITEM_ID_CAN_NOT_BE_0);
        if (parentReplyId == 0) {
            assert!(table::length(&postMetaData.comments) >= commentId, E_COMMENT_NOT_EXIST);
            let comment = table::borrow_mut(&mut postMetaData.comments, commentId - 1);
            comment

        } else {
            let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, parentReplyId);
            assert!(table::length(&replyMetaData.comments) >= commentId, E_COMMENT_NOT_EXIST);
            let commentMetaData = table::borrow_mut(&mut replyMetaData.comments, commentId - 1);
            commentMetaData
        }
    }

    public fun getMutableCommentContainerSafe(postMetaData: &mut PostMetaData, parentReplyId: u64, commentId: u64): &mut CommentMetaData {
        let commentMetaData = getMutableCommentMetaData(postMetaData, parentReplyId, commentId);
        assert!(!commentMetaData.isDeleted, E_COMMENT_DELETED);
        commentMetaData
    }

    public fun getCommentMetaData(postMetaData: &mut PostMetaData, parentReplyId: u64, commentId: u64): &CommentMetaData {
        getMutableCommentMetaData(postMetaData, parentReplyId, commentId)
    }

    public fun getCommentContainerSafe(postMetaData: &mut PostMetaData, parentReplyId: u64, commentId: u64): &CommentMetaData {
        getCommentContainerSafe(postMetaData, parentReplyId, commentId)
    }

    fun getActiveReplyCount(
        postMetaData: &PostMetaData
    ): u64 {
        return table::length(&postMetaData.replies) - postMetaData.deletedReplyCount
    }

    // public fun getPost(postCollection: &mut PostCollection, postId: u64): &mut Post {
    //     assert!(postId > 0, E_ITEM_ID_CAN_NOT_BE_0);
    //     assert!(vector::length(&postCollection.posts) >= postId, E_POST_NOT_EXIST);
    //     let post = vector::borrow_mut(&mut postCollection.posts, postId - 1);
    //     post
    // }

    // public fun getReply(postCollection: &mut PostCollection, postId: u64, replyId: u64): &mut Reply {
    //     let post = getPost(postCollection, postId);
    //     return getReplyContainer(post, replyId)
    // }

    // public fun getComment(postCollection: &mut PostCollection, postId: u64, replyId: u64, commentId: u64): &mut Comment {
    //     let post = getPost(postCollection, postId);
    //     return getCommentContainer(post, replyId, commentId)
    // }

    // #[test_only]
    // public fun getPostData(postCollection: &mut PostCollection, postId: u64): (u8, vector<u8>, u64, address, i64Lib::I64, u64, u64, u64, u64, bool, vector<u64>, vector<u8>, vector<u8>, vector<address>) {
    //     let post = getPost(postCollection, postId);
    //     (
    //         post.postType,
    //         commonLib::getIpfsHash(post.ipfsDoc),
    //         post.postTime,
    //         post.author,
    //         post.rating,
    //         post.communityId,
    //         post.officialReply,
    //         post.bestReply,
    //         post.deletedReplyCount,
    //         post.isDeleted,
    //         post.tags,
    //         post.properties,
    //         post.historyVotes,
    //         post.votedUsers
    //     )
    //     // replies: vector<Reply>,  // TODO: add
    //     // comments: vector<Comment>,   // TODO: add
    // }

    // #[test_only]
    // public fun getReplyData(postCollection: &mut PostCollection, postId: u64, replyId: u64): (vector<u8>, u64, address, i64Lib::I64, u64, bool, bool, bool, vector<u8>, vector<u8>, vector<address>) {
    //     let reply = getReply(postCollection, postId, replyId);

    //     (
    //         commonLib::getIpfsHash(reply.ipfsDoc),
    //         reply.postTime,
    //         reply.author,
    //         reply.rating,
    //         reply.parentReplyId,
    //         reply.isFirstReply,
    //         reply.isQuickReply,
    //         reply.isDeleted,
    //         reply.properties,
    //         reply.historyVotes,
    //         reply.votedUsers
    //     )
    //     // comments: vector<Comment>, // TODO: add
    // }

    // #[test_only]
    // public fun getCommentData(postCollection: &mut PostCollection, postId: u64, parentReplyId: u64, commentId: u64): (vector<u8>, u64, address, i64Lib::I64, bool, vector<u8>, vector<u8>, vector<address>) {
    //     let comment = getComment(postCollection, postId, parentReplyId, commentId);
        
    //     (
    //         commonLib::getIpfsHash(comment.ipfsDoc),
    //         comment.postTime,
    //         comment.author,
    //         comment.rating,

    //         comment.isDeleted,
    //         comment.properties,
    //         comment.historyVotes,
    //         comment.votedUsers
    //     )
    // }

    // #[test_only]
    // public fun create_post(
    //     postCollection: &mut PostCollection,
    //     communityCollection: &mut communityLib::CommunityCollection,
    //     userCollection: &mut userLib::UserCollection,
    //     ctx: &mut TxContext
    // ) {
    //     createPost(
    //         postCollection,
    //         communityCollection,
    //         userCollection,
    //         1,
    //         x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
    //         EXPERT_POST,
    //         vector<u64>[1, 2],
    //         ctx
    //     );
    // }

    // #[test_only]
    // public fun create_post_with_type(
    //     postCollection: &mut PostCollection,
    //     communityCollection: &mut communityLib::CommunityCollection,
    //     userCollection: &mut userLib::UserCollection,
    //     postType: u8,
    //     ctx: &mut TxContext
    // ) {
    //     createPost(
    //         postCollection,
    //         communityCollection,
    //         userCollection,
    //         1,
    //         x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
    //         postType,
    //         vector<u64>[1, 2],
    //         ctx
    //     );
    // }

    // #[test_only]
    // public fun create_reply(
    //     postCollection: &mut PostCollection,
    //     ctx: &mut TxContext
    // ) {
    //     createReply(
    //         postCollection,
    //         1,
    //         0,
    //         x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
    //         false,
    //         ctx
    //     );
    // }


    ///
    //voteLib
    ///
    struct StructRating has drop {
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
    const ACCEPTED_EXPERT_REPLY: u64 = 15;
    const ACCEPT_EXPERT_REPLY: u64 = 2;
    const FIRST_EXPERT_REPLY: u64 = 5;
    const QUICK_EXPERT_REPLY: u64 = 5;

    //common reply 
    const DOWNVOTE_COMMON_REPLY: u64 = 1;       // negative
    const UPVOTED_COMMON_REPLY: u64 = 1;
    const DOWNVOTED_COMMON_REPLY: u64 = 1;      // negative
    const ACCEPTED_COMMON_REPLY: u64 = 3;
    const ACCEPT_COMMON_REPLY: u64 = 1;
    const FIRST_COMMON_REPLY: u64 = 1;
    const QUICK_COMMON_REPLY: u64 = 1;
    
    const DELETE_OWN_REPLY: u64 = 1;            // negative
    const MODERATOR_DELETE_REPLY: u64 = 2;      // negative     // to do

/////////////////////////////////////////////////////////////////////////////////

    const MODERATOR_DELETE_COMMENT: u64 = 1;    // negative

    fun getExpertRating(): StructRating {
        StructRating {
            upvotedPost: i64Lib::from(UPVOTED_EXPERT_POST),
            downvotedPost: i64Lib::neg_from(DOWNVOTED_EXPERT_POST),

            upvotedReply: i64Lib::from(UPVOTED_EXPERT_REPLY),
            downvotedReply: i64Lib::neg_from(DOWNVOTED_EXPERT_REPLY),
            firstReply: i64Lib::from(FIRST_EXPERT_REPLY),
            quickReply: i64Lib::from(QUICK_EXPERT_REPLY),
            acceptedReply: i64Lib::from(ACCEPTED_EXPERT_REPLY),
            acceptReply: i64Lib::from(ACCEPT_EXPERT_REPLY)
        }
    }

    fun getCommonRating(): StructRating {
        StructRating {
            upvotedPost: i64Lib::from(UPVOTED_COMMON_POST),
            downvotedPost: i64Lib::neg_from(DOWNVOTED_COMMON_POST),

            upvotedReply: i64Lib::from(UPVOTED_COMMON_REPLY),
            downvotedReply: i64Lib::neg_from(DOWNVOTED_COMMON_REPLY),
            firstReply: i64Lib::from(FIRST_COMMON_REPLY),
            quickReply: i64Lib::from(QUICK_COMMON_REPLY),
            acceptedReply: i64Lib::from(ACCEPTED_COMMON_REPLY),
            acceptReply: i64Lib::from(ACCEPT_COMMON_REPLY)
        }
    }

    fun getTutorialRating(): StructRating {
        StructRating {
            upvotedPost: i64Lib::from(UPVOTED_TUTORIAL),
            downvotedPost: i64Lib::neg_from(DOWNVOTED_TUTORIAL),

            upvotedReply: i64Lib::zero(),
            downvotedReply: i64Lib::zero(),
            firstReply: i64Lib::zero(),
            quickReply: i64Lib::zero(),
            acceptedReply: i64Lib::zero(),
            acceptReply: i64Lib::zero()
        }
    }

    fun getUserRatingChangeForPostAction(
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

        } else if (postType == TUTORIAL) {
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
            else if (resourceAction == RESOURCE_ACTION_ACCEPTED_REPLY) i64Lib::from(ACCEPTED_EXPERT_REPLY)
            else if (resourceAction == RESOURCE_ACTION_ACCEPT_REPLY) i64Lib::from(ACCEPT_EXPERT_REPLY)
            else if (resourceAction == RESOURCE_ACTION_FIRST_REPLY) i64Lib::from(FIRST_EXPERT_REPLY)
            else if (resourceAction == RESOURCE_ACTION_QUICK_REPLY) i64Lib::from(QUICK_EXPERT_REPLY)
            else abort E_INVALID_RESOURCE_TYPE

        } else if (postType == COMMON_POST) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_ACCEPTED_REPLY) i64Lib::from(ACCEPTED_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_ACCEPT_REPLY) i64Lib::from(ACCEPT_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_FIRST_REPLY) i64Lib::from(FIRST_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_QUICK_REPLY) i64Lib::from(QUICK_COMMON_REPLY)
            else abort E_INVALID_RESOURCE_TYPE

        } else if (postType == TUTORIAL) {
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
    
    ///
    //  historyVotes: -> todo: add const
    // 1 - downVote
    // 2 - cancelVote
    // 3 - upvote
    // toDo describe return value
    public fun getForumItemRatingChange(
        userActionId: ID,
        historyVotes: &mut vector<u8>,
        isUpvote: bool,
        votedUsers: &mut vector<ID>
    ): (i64Lib::I64, bool) {
        let (history, userPosition, isExistVote) = getHistoryVote(userActionId, *historyVotes, *votedUsers);
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
                    vector::push_back(votedUsers, userActionId);
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
                    vector::push_back(votedUsers, userActionId);
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
        userId: ID,
        historyVotes: vector<u8>,
        votedUsers: vector<ID>
    ): (u8, u64, bool) { // (status vote, isExistVote)
        let (isExist, position) = vector::index_of(&mut votedUsers, &userId);

        if (isExist) {
            let voteVolue = vector::borrow(&mut historyVotes, position);
            (*voteVolue, position, true)
        } else {
            (2, 0, false)
        }
    }
}
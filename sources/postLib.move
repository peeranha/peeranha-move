module basics::postLib {    
    use sui::transfer;
    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::clock::{Clock};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use std::vector;
    use basics::accessControl;
    use basics::communityLib;
    use basics::commonLib;
    use basics::userLib;
    use basics::i64Lib;
    // use sui::dynamic_object_field as ofield;

    use sui::table::{Self, Table};
    // use sui::bag::{Self, Bag};

    // ====== Errors ======

    const E_INVALID_POST_TYPE: u64 = 31;

    const E_INVALID_RESOURCE_TYPE: u64 = 32;

    const E_ITEM_ID_CAN_NOT_BE_0: u64 = 40;

    const E_USER_CAN_NOT_PUBLISH_2_REPLIES_FOR_POST: u64 = 41;

    const E_NOT_ALLOWED_EDIT_NOT_AUTHOR: u64 = 42;

    // const E_YOU_CAN_NOT_EDIT_THIS_REPLY_IT_IS_NOT_YOUR: u64 = 43;

    // const E_YOU_CAN_NOT_EDIT_THIS_COMMENT_IT_IS_NOT_YOUR: u64 = 44;

    const E_YOU_CAN_NOT_DELETE_THE_BEST_REPLY: u64 = 45;

    const E_YOU_CAN_NOT_PUBLISH_REPLIES_IN_TUTORIAL: u64 = 46;

    const E_USER_IS_FORBIDDEN_TO_REPLY_ON_REPLY_FOR_EXPERT_AND_COMMON_TYPE_OF_POST: u64 = 47;       // name

    const E_THIS_POST_TYPE_IS_ALREADY_SET: u64 = 49;        // deleted

    const E_ERROR_POST_TYPE: u64 = 50;      ///

    const E_ERROR_VOTE_COMMENT: u64 = 51;

    const E_ERROR_VOTE_REPLY: u64 = 52;

    const E_ERROR_VOTE_POST: u64 = 53;

    const E_POST_NOT_EXIST: u64 = 55;

    const E_REPLY_NOT_EXIST: u64 = 56;

    const E_COMMENT_NOT_EXIST: u64 = 57;

    const E_POST_DELETED: u64 = 58;

    const E_REPLY_DELETED: u64 = 59;

    const E_COMMENT_DELETED: u64 = 60;

    const E_ERROR_CHANGE_COMMUNITY_ID: u64 = 61;

    const E_ONLY_OWNER_BY_POST_CAN_CHANGE_STATUS_BEST_REPLY: u64 = 64;

    const E_WRONG_SIGNER: u64 = 64;

    const E_ITEM_ID_NOT_MATCHING: u64 = 65;

    const E_AT_LEAST_ONE_TAG_IS_REQUIRED: u64 = 86;

    const E_INVALID_LANGUAGE: u64 = 67;

    // 98, 99 - getPeriodRating  ???

    // ====== Constant ======

    const QUICK_REPLY_TIME_SECONDS: u64 = 900 * 1000; // 15 minute
    const DELETE_TIME: u64 = 604800 * 1000;    //7 days
    // const DEFAULT_COMMUNITY: ID = object::id_from_address(@0x0);

    // ====== Enum ======

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;

    const ENGLISH_LANGUAGE: u8 = 0;
    const CHINESE_LANGUAGE: u8 = 1;
    const SPANISH_LANGUAGE: u8 = 2;
    const VIETNAMESE_LANGUAGE: u8 = 3;
    const LANGUAGE_LENGTH: u8 = 4; // Update after add new language

    const DIRECTION_DOWNVOTE: u8 = 4;
    const DIRECTION_CANCEL_DOWNVOTE: u8 = 0;
    const DIRECTION_UPVOTE: u8 = 3;
    const DIRECTION_CANCEL_UPVOTE: u8 = 1;

    const TYPE_CONTENT_POST: u8 = 0;
    const TYPE_CONTENT_REPLY: u8 = 1;
    const TYPE_CONTENT_COMMENT: u8 = 2;

    const DOWNVOTE: u8 = 1;
    const NONE_VOTE: u8 = 2;
    const UPVOTE: u8 = 3;

    struct Post has key {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,
    }

    struct PostMetaData has key {       // shared
        id: UID,
        postId: ID,
        postType: u8,
        postTime: u64,
        author: ID,
        rating: i64Lib::I64,
        communityId: ID,
        language: u8,

        officialReplyMetaDataKey: u64,
        bestReplyMetaDataKey: u64,
        deletedReplyCount: u64,
        isDeleted: bool,

        tags: vector<u64>,
        replies: Table<u64, ReplyMetaData>,
        comments: Table<u64, CommentMetaData>,
        properties: VecMap<u8, vector<u8>>,
        historyVotes: VecMap<ID, u8>,       // downVote = 1, NONE = 2, upVote = 3 // rewrite look getForumItemRatingChange
    }

    struct Reply has key {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,
    }

    struct ReplyMetaData has key, store {
        id: UID,
        replyId: ID,
        postTime: u64,
        author: ID,
        rating: i64Lib::I64,
        parentReplyMetaDataKey: u64,
        language: u8,

        isFirstReply: bool,
        isQuickReply: bool,
        isDeleted: bool,

        comments: Table<u64, CommentMetaData>,
        properties: VecMap<u8, vector<u8>>,
        historyVotes: VecMap<ID, u8>,       // downVote = 1, NONE = 2, upVote = 3 // rewrite look getForumItemRatingChange
    }

    struct Comment has key {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,

    }

    struct CommentMetaData has key, store {
        id: UID,
        commentId: ID,
        postTime: u64,
        author: ID,
        rating: i64Lib::I64,
        language: u8,

        isDeleted: bool,
        properties: VecMap<u8, vector<u8>>,
        historyVotes: VecMap<ID, u8>,       // downVote = 1, NONE = 2, upVote = 3 // rewrite look getForumItemRatingChange
    }

    struct UserRatingChange {
        user: userLib::User,
        userCommunityRating: userLib::UserCommunityRating,
        rating: i64Lib::I64
    }

    // ====== Events ======

    struct CreatePostEvent has copy, drop {
        userId: ID,
        communityId: ID,
        postMetaDataId: ID,
    }

    struct CreateReplyEvent has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        parentReplyKey: u64,
        replyMetaDataKey: u64,
    }

    struct CreateCommentEvent has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        parentReplyKey: u64,
        commentMetaDataKey: u64,
    }

    struct EditPostEvent has copy, drop {
        userId: ID,
        postMetaDataId: ID,
    }

    struct ModeratorEditPostEvent has copy, drop {
        userId: ID,
        postMetaDataId: ID,
    }

    struct EditReplyEvent has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        replyMetaDataKey: u64,
    }

    struct ModeratorEditReplyEvent has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        replyMetaDataKey: u64,
    }

    struct EditCommentEvent has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        parentReplyKey: u64,
        commentMetaDataKey: u64,
    }

    struct DeletePostEvent has copy, drop {
        userId: ID,
        postMetaDataId: ID,
    }

    struct DeleteReplyEvent has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        replyMetaDataKey: u64,
    }

    struct DeleteCommentEvent has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        parentReplyKey: u64,
        commentMetaDataKey: u64,
    }

    struct ChangeStatusBestReply has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        replyMetaDataKey: u64,
    }

    struct VoteItem has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        replyMetaDataKey: u64,
        commentMetaDataKey: u64,
        voteDirection: u8,
    }

    // event TranslationCreated(address indexed user, uint256 indexed postId, uint16 replyMetaDataKey, uint8 commentMetaDataKey, Language language);
    // event TranslationEdited(address indexed user, uint256 indexed postId, uint16 replyMetaDataKey, uint8 commentMetaDataKey, Language language);
    // event TranslationDeleted(address indexed user, uint256 indexed postId, uint16 replyMetaDataKey, uint8 commentMetaDataKey, Language language);

    public entry fun createPost(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        time: &Clock,
        user: &mut userLib::User,
        community: &communityLib::Community,
        ipfsHash: vector<u8>, 
        postType: u8,
        tags: vector<u64>,
        language: u8,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let userCommunityRating = userLib::getUserCommunityRating(usersRatingCollection, object::id(user));
        
        communityLib::onlyNotFrezenCommunity(community);
        communityLib::checkTags(community, tags);
        let communityId = object::id(community);
        userLib::checkActionRole(                               // test
            user,
            userCommunityRating,
            userRolesCollection,
            userId,
            userId,
            communityId,
            userLib::get_action_publication_post(),
            accessControl::get_action_role_none(),
            /*true*/
        );

        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);

        assert!(vector::length(&mut tags) > 0, E_AT_LEAST_ONE_TAG_IS_REQUIRED);
        let postTags = tags;

        let post = Post {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
        };
        let postMetaData = PostMetaData {
            id: object::new(ctx),
            postId: object::id(&post),
            postType: postType,
            postTime: commonLib::getTimestamp(time),
            author: userId,
            rating: i64Lib::zero(),
            communityId: communityId,
            officialReplyMetaDataKey: 0,
            bestReplyMetaDataKey: 0,
            deletedReplyCount: 0,
            language: language,
            isDeleted: false,
            tags: postTags,
            replies: table::new(ctx),
            comments: table::new(ctx),
            properties: vec_map::empty(),
            historyVotes: vec_map::empty(),
        };

        event::emit(CreatePostEvent{userId: userId, communityId: communityId, postMetaDataId: object::id(&postMetaData)});
        transfer::share_object(
            postMetaData
        );
        transfer::transfer(
            post,
            tx_context::sender(ctx)
        );
    }

    public entry fun createReply(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        time: &Clock,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyMetaDataKey: u64,
        ipfsHash: vector<u8>,
        isOfficialReply: bool,
        language: u8,
        ctx: &mut TxContext
    ) {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let userId = object::id(user);
        let userCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, userId);

        assert!(postMetaData.postType != TUTORIAL, E_YOU_CAN_NOT_PUBLISH_REPLIES_IN_TUTORIAL);
        assert!(parentReplyMetaDataKey == 0, E_USER_IS_FORBIDDEN_TO_REPLY_ON_REPLY_FOR_EXPERT_AND_COMMON_TYPE_OF_POST);
        let communityId = postMetaData.communityId;
        userLib::checkActionRole(                       // test
            user,
            userCommunityRating,
            userRolesCollection,
            userId,
            postMetaData.author,
            communityId,
            userLib::get_action_publication_reply(),
            if (parentReplyMetaDataKey == 0 && isOfficialReply)     //parentReplyMetaDataKey need?
                accessControl::get_action_role_community_admin() else
                accessControl::get_action_role_none()
            /*true*/
        );
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);

        let countReplies = table::length(&postMetaData.replies);
        if (postMetaData.postType == EXPERT_POST || postMetaData.postType == COMMON_POST) {
            let replyMetaDataKey = 1;
            while (replyMetaDataKey <= countReplies) {
                let replyContainer = getReplyMetaData(postMetaData, replyMetaDataKey);
                assert!(
                    userId != replyContainer.author || replyContainer.isDeleted,
                    E_USER_CAN_NOT_PUBLISH_2_REPLIES_FOR_POST
                );
                replyMetaDataKey = replyMetaDataKey + 1;
            };
        };

        let replyUID = object::new(ctx);
        let isFirstReply = false;
        let isQuickReply = false;
        let timestamp: u64 = commonLib::getTimestamp(time);
        if (isOfficialReply) {
            postMetaData.officialReplyMetaDataKey = countReplies + 1;
        };

        if (postMetaData.author != userId) {
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

        let reply = Reply {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
        };
        let replyMetaData = ReplyMetaData {
            id: replyUID,
            replyId: object::id(&reply),
            postTime: timestamp,
            author: userId,
            rating: i64Lib::zero(),
            parentReplyMetaDataKey: parentReplyMetaDataKey,
            language: language,
              
            isFirstReply: isFirstReply,
            isQuickReply: isQuickReply,
            isDeleted: false,

            comments: table::new(ctx),
            properties: vec_map::empty(),
            historyVotes: vec_map::empty(),
        };

        let replyMetaDataKey = countReplies + 1;
        event::emit(CreateReplyEvent{userId: userId, postMetaDataId: object::id(postMetaData), parentReplyKey: parentReplyMetaDataKey, replyMetaDataKey: replyMetaDataKey});
        table::add(&mut postMetaData.replies, replyMetaDataKey, replyMetaData);
        transfer::transfer(
            reply,
            tx_context::sender(ctx)
        );
    }

    public entry fun createComment(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        time: &Clock,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyMetaDataKey: u64,
        ipfsHash: vector<u8>,
        language: u8,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let userCommunityRating = userLib::getUserCommunityRating(usersRatingCollection, userId);
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);

        let comment = Comment {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
        };
        let commentId = object::id(&comment);
        let commentMetaData = CommentMetaData {
            id: object::new(ctx),
            commentId: commentId,
            postTime: commonLib::getTimestamp(time),
            author: userId,
            rating: i64Lib::zero(),
            isDeleted: false,
            language: language,

            properties: vec_map::empty(),
            historyVotes: vec_map::empty(),
        };
        let commentMetaDataKey;
        let dataUser = postMetaData.author;
        if (parentReplyMetaDataKey == 0) {
            assert!(!postMetaData.isDeleted, E_POST_DELETED);
            commentMetaDataKey = table::length(&postMetaData.comments) + 1;
            table::add(&mut postMetaData.comments, commentMetaDataKey, commentMetaData);
        } else {
            let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, parentReplyMetaDataKey);
            dataUser = replyMetaData.author;
            commentMetaDataKey = table::length(&replyMetaData.comments) + 1;
            table::add(&mut replyMetaData.comments, commentMetaDataKey, commentMetaData);
        };

        userLib::checkActionRole(       // test
            user,
            userCommunityRating,
            userRolesCollection,
            userId,
            dataUser,
            postMetaData.communityId,
            userLib::get_action_publication_comment(),
            accessControl::get_action_role_none(),
            /*true*/
        );

        transfer::transfer(
            comment,
            tx_context::sender(ctx)
        );

        event::emit(CreateCommentEvent{userId: userId, postMetaDataId: object::id(postMetaData), parentReplyKey: parentReplyMetaDataKey, commentMetaDataKey: commentMetaDataKey});
    }

    public entry fun authorEditPost(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        user: &mut userLib::User,
        post: &mut Post,
        postMetaData: &mut PostMetaData,
        newCommunity: &communityLib::Community,
        ipfsHash: vector<u8>, 
        newPostType: u8,
        tags: vector<u64>,
        language: u8,
        ctx: &mut TxContext
    ) {
        checkMatchItemId(object::id(post), postMetaData.postId);
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        if(commonLib::getIpfsHash(post.ipfsDoc) != ipfsHash)
            post.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        editPost(
            usersRatingCollection,
            userRolesCollection,
            periodRewardContainer,
            user,
            postMetaData,
            newCommunity,
            newPostType,
            tags,
            language,
            ctx
        );
        event::emit(EditPostEvent{userId: object::id(user), postMetaDataId: object::id(postMetaData)});
    }

    public entry fun moderatorEditPostMetaData(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        newCommunity: &communityLib::Community,
        newPostType: u8,
        tags: vector<u64>,
        language: u8,
        ctx: &mut TxContext
    ) {
        // fix
        let _newCommunityId = object::id(newCommunity);
        // if (newCommunityId != postMetaData.communityId /*&& newCommunityId != DEFAULT_COMMUNITY *//*&& !self.peeranhaUser.isProtocolAdmin(userAddr)*/) // todo new transfer 
        //     abort E_ERROR_CHANGE_COMMUNITY_ID;  // test

        editPost(
            usersRatingCollection,
            userRolesCollection,
            periodRewardContainer,
            user,
            postMetaData,
            newCommunity,
            newPostType,
            tags,
            language,
            ctx
        );
        event::emit(ModeratorEditPostEvent{userId: object::id(user), postMetaDataId: object::id(postMetaData)});
    }

    fun editPost(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        newCommunity: &communityLib::Community,
        newPostType: u8,
        tags: vector<u64>,
        language: u8,
        ctx: &mut TxContext
    ) {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let userId = object::id(user);
        let userCommunityRating = userLib::getUserCommunityRating(usersRatingCollection, userId);

        let postMetaDataAuthor = postMetaData.author;
        userLib::checkActionRole(                       // test               
            user,
            userCommunityRating,
            userRolesCollection,
            userId,
            postMetaDataAuthor,
            postMetaData.communityId,
            if (userId == postMetaDataAuthor)
                userLib::get_action_edit_item() else
                userLib::get_action_none(),
            if (userId == postMetaDataAuthor)
                accessControl::get_action_role_none() else
                accessControl::get_action_role_admin_or_community_moderator(),
            /*false*/
        );

        changePostType(usersRatingCollection, periodRewardContainer, postMetaData, newPostType, ctx);
        changePostCommunity(usersRatingCollection, periodRewardContainer, postMetaData, newCommunity, ctx);

        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);
        if (postMetaData.language != language) {
            postMetaData.language = language;
        };
        
        if(vector::length(&tags) > 0) {
            communityLib::checkTags(newCommunity, tags);
            postMetaData.tags = tags;
        };

        event::emit(EditPostEvent{userId: userId, postMetaDataId: object::id(postMetaData)});
    }

    public entry fun authorEditReply(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        reply: &mut Reply,
        replyMetaDataKey: u64,
        ipfsHash: vector<u8>, 
        isOfficialReply: bool,
        language: u8,
    ) {
        // checkMatchItemId(object::id(reply), replyMetaData.replyId);                           // todo????        // test
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        if (commonLib::getIpfsHash(reply.ipfsDoc) != ipfsHash)
            reply.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        editReply(
            usersRatingCollection,
            userRolesCollection,
            user,
            postMetaData,
            replyMetaDataKey,
            isOfficialReply,
            language
        );
        event::emit(EditReplyEvent{userId: object::id(user), postMetaDataId: object::id(postMetaData), replyMetaDataKey: replyMetaDataKey});
    }

    public entry fun moderatorEditReply(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        replyMetaDataKey: u64,
        isOfficialReply: bool,
        language: u8,
    ) {
        editReply(
            usersRatingCollection,
            userRolesCollection,
            user,
            postMetaData,
            replyMetaDataKey,
            isOfficialReply,
            language
        );
        event::emit(ModeratorEditReplyEvent{userId: object::id(user), postMetaDataId: object::id(postMetaData), replyMetaDataKey: replyMetaDataKey});
    }

    fun editReply(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        replyMetaDataKey: u64,
        isOfficialReply: bool,
        language: u8,
    ) {
        let userId = object::id(user);
        let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, replyMetaDataKey); // test moderator or checkMatchItemId exist deleted
        let userCommunityRating = userLib::getUserCommunityRating(usersRatingCollection, userId);

        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);
        if (replyMetaData.language != language) {
            replyMetaData.language = language;
        };

        userLib::checkActionRole(               // test
            user,
            userCommunityRating,
            userRolesCollection,
            userId,
            replyMetaData.author,
            postMetaData.communityId,
            userLib::get_action_edit_item(),
            if (isOfficialReply)
                accessControl::get_action_role_community_admin() else
                accessControl::get_action_role_none(),
            /*false*/
        );

        if (isOfficialReply) {
            postMetaData.officialReplyMetaDataKey = replyMetaDataKey;
        } else if (postMetaData.officialReplyMetaDataKey == replyMetaDataKey) {
            postMetaData.officialReplyMetaDataKey = 0;
        };
    }

    public entry fun editComment(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        comment: &mut Comment,
        parentReplyKey: u64,
        commentMetaDataKey: u64,
        ipfsHash: vector<u8>,
        language: u8,
    ) {
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        let userId = object::id(user);
        let commentMetaData = getMutableCommentMetaDataSafe(postMetaData, parentReplyKey, commentMetaDataKey);
        checkMatchItemId(object::id(comment), commentMetaData.commentId);
        let userCommunityRating = userLib::getUserCommunityRating(usersRatingCollection, userId);

        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);
        if (commentMetaData.language != language) {
            commentMetaData.language = language;
        };

        userLib::checkActionRole(               // test
            user,
            userCommunityRating,
            userRolesCollection,
            userId,
            commentMetaData.author,
            postMetaData.communityId,
            userLib::get_action_edit_item(),
            accessControl::get_action_role_none(),
            /*false*/
        );

        if (commonLib::getIpfsHash(comment.ipfsDoc) != ipfsHash)
            comment.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        event::emit(EditCommentEvent{userId: userId, postMetaDataId: object::id(postMetaData), parentReplyKey: parentReplyKey, commentMetaDataKey: commentMetaDataKey});
    }

    public entry fun deletePost(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        time: &Clock,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        ctx: &mut TxContext
    ) {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let communityId = postMetaData.communityId;
        let postAuthor = postMetaData.author;
        let bestReplyMetaDataKey = postMetaData.bestReplyMetaDataKey;
        let userId = object::id(user);
        let userCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, userId);
        userLib::checkActionRole(           // test
            user,
            userCommunityRating,
            userRolesCollection,
            userId,
            postAuthor,
            communityId,
            userLib::get_action_delete_item(),
            accessControl::get_action_role_none(),
            /*false*/
        );

        let postType = postMetaData.postType;
        let time: u64 = commonLib::getTimestamp(time);
        let changeUserRating: i64Lib::I64 = i64Lib::zero();
        if (time - postMetaData.postTime < DELETE_TIME || userId == postAuthor) {
            let typeRating: StructRating = getTypesRating(postType);

            let (positive, negative) = getHistoryInformations(postMetaData.historyVotes);
            let changeVoteUserRating: i64Lib::I64 = i64Lib::add(&i64Lib::mul(&typeRating.upvotedPost, &i64Lib::from(positive)), &i64Lib::mul(&typeRating.downvotedPost, &i64Lib::from(negative)));
            if (i64Lib::compare(&changeVoteUserRating, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                changeUserRating = i64Lib::sub(&changeUserRating, &changeVoteUserRating);
            };
        };
        if (bestReplyMetaDataKey != 0) {
            changeUserRating = i64Lib::sub(&changeUserRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPTED_REPLY));
        };

        changeUserRating = i64Lib::sub(&changeUserRating, if(userId == postAuthor)
            &i64Lib::from(DELETE_OWN_POST) else
            &i64Lib::from(MODERATOR_DELETE_POST));
        userLib::updateRating(
            userCommunityRating,
            periodRewardContainer,
            userId,
            changeUserRating,
            communityId,
            ctx
        );

        if (time - postMetaData.postTime < DELETE_TIME || userId == postAuthor) {
            let replyCount = table::length(&postMetaData.replies);
            let replyMetaDataKey = 1;

            while (replyMetaDataKey <= replyCount) {
                let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
                let replyAuthorCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, replyMetaData.author);

                deductReplyRating(
                    replyAuthorCommunityRating,
                    periodRewardContainer,
                    replyMetaData,
                    postType,
                    bestReplyMetaDataKey == replyMetaDataKey,
                    communityId,
                    ctx
                );
                replyMetaDataKey = replyMetaDataKey + 1;
            }
        };

        postMetaData.isDeleted = true;
        event::emit(DeletePostEvent{userId: userId, postMetaDataId: object::id(postMetaData)});
    }

    public entry fun deleteReply(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        time: &Clock,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        replyMetaDataKey: u64,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let communityId = postMetaData.communityId;
        let userCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, object::id(user));
        
        postMetaData.deletedReplyCount = postMetaData.deletedReplyCount + 1;
        let isBestReplyMetaData = postMetaData.bestReplyMetaDataKey == replyMetaDataKey;
        if (isBestReplyMetaData) {
            postMetaData.bestReplyMetaDataKey = 0;
        };

        if (postMetaData.officialReplyMetaDataKey == replyMetaDataKey)
            postMetaData.officialReplyMetaDataKey = 0;
        let postType = postMetaData.postType;
        
        let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, replyMetaDataKey);
        userLib::checkActionRole(  // test
            user,
            userCommunityRating,
            userRolesCollection,
            userId,
            replyMetaData.author,
            communityId,
            userLib::get_action_delete_item(),
            accessControl::get_action_role_none(),
            /*false*/
        );
        
        // admin can delete best reply
        assert!(userId != replyMetaData.author || !isBestReplyMetaData, E_YOU_CAN_NOT_DELETE_THE_BEST_REPLY);
        
        let time: u64 = commonLib::getTimestamp(time);
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
        let parentReplyMetaDataKey = replyMetaData.parentReplyMetaDataKey;
        if (isDeductReplyRating) {
            deductReplyRating(
                userCommunityRating,
                periodRewardContainer,
                replyMetaData,
                postType,
                parentReplyMetaDataKey == 0 && isBestReplyMetaData,
                communityId,
                ctx
            );
        };
        event::emit(DeleteReplyEvent{userId: object::id(user), postMetaDataId: object::id(postMetaData), replyMetaDataKey: replyMetaDataKey});
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
        if (replyMetaData.isDeleted)    // test rating
            return;

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
        let (positive, negative) = getHistoryInformations(replyMetaData.historyVotes);
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
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyKey: u64,
        commentMetaDataKey: u64,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        let communityId = postMetaData.communityId;
        let commentMetaData = getMutableCommentMetaDataSafe(postMetaData, parentReplyKey, commentMetaDataKey);
        let userCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, object::id(user));
        
        userLib::checkActionRole(         // test
            user,
            userCommunityRating,
            userRolesCollection,
            userId,
            commentMetaData.author,
            communityId,
            userLib::get_action_delete_item(),
            accessControl::get_action_role_none(),
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
        event::emit(DeleteCommentEvent{userId: userId, postMetaDataId: object::id(postMetaData), parentReplyKey: parentReplyKey, commentMetaDataKey: commentMetaDataKey});
    }

    public entry fun changeStatusBestReply(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        postAuthor: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        newBestReplyMetaDataKey: u64,
        ctx: &mut TxContext
    ) {
        let newBestReplyMetaData = getReplyMetaDataSafe(postMetaData, newBestReplyMetaDataKey);
        let communityId = postMetaData.communityId;
        assert!(postMetaData.author == object::id(postAuthor), E_ONLY_OWNER_BY_POST_CAN_CHANGE_STATUS_BEST_REPLY);

        if (postMetaData.bestReplyMetaDataKey == newBestReplyMetaDataKey) {
            updateRatingForBestReply(
                usersRatingCollection,
                periodRewardContainer,
                postMetaData.author,
                newBestReplyMetaData.author,
                postMetaData.postType,
                false,
                communityId,
                ctx
            );
            postMetaData.bestReplyMetaDataKey = 0;
        } else {
            if (postMetaData.bestReplyMetaDataKey != 0) {
                let bestReplyMetaDataKey = postMetaData.bestReplyMetaDataKey;
                let oldBestReplyMetaData = getReplyMetaDataSafe(postMetaData, bestReplyMetaDataKey);
                updateRatingForBestReply(
                    usersRatingCollection,
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
                usersRatingCollection,
                periodRewardContainer,
                postMetaData.author,
                newBestReplyMetaData.author,
                postMetaData.postType,
                true,
                communityId,
                ctx
            );
            postMetaData.bestReplyMetaDataKey = newBestReplyMetaDataKey;
        };
        let postAuthorId = object::id(postAuthor);
        let postAuthorCommunityRating = userLib::getUserCommunityRating(usersRatingCollection, postMetaData.author);
        userLib::checkActionRole(    // test
            postAuthor,
            postAuthorCommunityRating,
            userRolesCollection,
            postAuthorId,
            postMetaData.author,
            communityId,
            userLib::get_action_best_reply(),
            accessControl::get_action_role_none(),
            //false
        );

        event::emit(ChangeStatusBestReply{userId: object::id(postAuthor), postMetaDataId: object::id(postMetaData), replyMetaDataKey: newBestReplyMetaDataKey});
    }

    
    fun updateRatingForBestReply(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        postAuthorAddress: ID,
        replyAuthorAddress: ID,
        postType: u8,
        isMark: bool,
        communityId: ID,
        ctx: &mut TxContext
    ) {
        if (postAuthorAddress != replyAuthorAddress) {
            let postAuthorCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, postAuthorAddress);
            userLib::updateRating(
                postAuthorCommunityRating,
                periodRewardContainer,
                postAuthorAddress,
                if (isMark)
                    getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPT_REPLY) else
                    i64Lib::mul(&getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPT_REPLY), &i64Lib::neg_from(1)),
                communityId,
                ctx
            );

            let replyAuthorCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, replyAuthorAddress);
            userLib::updateRating(
                replyAuthorCommunityRating,
                periodRewardContainer,
                replyAuthorAddress,
                if (isMark)
                    getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPTED_REPLY) else
                    i64Lib::mul(&getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPTED_REPLY), &i64Lib::neg_from(1)),
                communityId,
                ctx
            );
        }
    }

    public entry fun votePost(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        voteUser: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        isUpvote: bool,
        ctx: &mut TxContext
    ) {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let postType = postMetaData.postType;
        let voteUserId = object::id(voteUser);
        let communityId = postMetaData.communityId;
        assert!(voteUserId != postMetaData.author, E_ERROR_VOTE_POST);
        
        let (ratingChange, isCancel) = getForumItemRatingChange(voteUserId, &mut postMetaData.historyVotes, isUpvote);
        let voteUserCommunityRating = userLib::getUserCommunityRating(usersRatingCollection, voteUserId);
        userLib::checkActionRole(
            voteUser,
            voteUserCommunityRating,
            userRolesCollection,
            voteUserId,
            postMetaData.author,
            communityId,
            if(isCancel) 
                userLib::get_action_cancel_vote() else 
                    if(i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) 
                        userLib::get_action_upvote_post() else 
                        userLib::get_action_downvote_post(),
            accessControl::get_action_role_none(),
            /*false*/
        );

        vote(
            usersRatingCollection,
            periodRewardContainer,
            voteUserId,
            postMetaData.author,
            postType,
            isUpvote,
            ratingChange,
            TYPE_CONTENT_POST,
            communityId,
            ctx
        );
        postMetaData.rating = i64Lib::add(&postMetaData.rating, &ratingChange);

        let voteDirection;
        if (isCancel) {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                voteDirection = DIRECTION_CANCEL_DOWNVOTE;
            } else {
                voteDirection = DIRECTION_CANCEL_UPVOTE;
            };
        } else {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                voteDirection = DIRECTION_UPVOTE;
            } else {
                voteDirection = DIRECTION_DOWNVOTE;
            };
        };

        event::emit(VoteItem{userId: voteUserId, postMetaDataId: object::id(postMetaData), replyMetaDataKey: 0, commentMetaDataKey: 0, voteDirection: voteDirection});
    }

    public entry fun voteReply(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        voteUser: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        replyMetaDataKey: u64,
        isUpvote: bool,
        ctx: &mut TxContext
    ) {
        // E_POST_DELETED           // test
        let postType = postMetaData.postType;
        let voteUserId = object::id(voteUser);
        let communityId = postMetaData.communityId;
        let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, replyMetaDataKey); // test exist/deleted
        assert!(voteUserId != replyMetaData.author, E_ERROR_VOTE_REPLY); // test

        let (ratingChange, isCancel) = getForumItemRatingChange(voteUserId, &mut replyMetaData.historyVotes, isUpvote);
        let voteUserCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, voteUserId);
        userLib::checkActionRole(    // test
            voteUser,
            voteUserCommunityRating,
            userRolesCollection,
            voteUserId,
            replyMetaData.author,
            communityId,
            if(isCancel) 
                userLib::get_action_cancel_vote() else 
                    if(i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) 
                        userLib::get_action_upvote_reply() else 
                        userLib::get_action_downvote_reply(),
            accessControl::get_action_role_none(),
            /*false*/
        );

        let oldRating: i64Lib::I64 = replyMetaData.rating;
        replyMetaData.rating = i64Lib::add(&replyMetaData.rating, &ratingChange);
        let newRating: i64Lib::I64 = replyMetaData.rating;

        let changeReplyAuthorRating: i64Lib::I64 = i64Lib::zero();
        if (replyMetaData.isFirstReply) {  // oldRating < 0 && newRating >= 0
            if (i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getLessThan() && (i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getEual())) {
                changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_FIRST_REPLY));
            } else if ((i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getEual()) && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getLessThan()) { // (oldRating >= 0 && newRating < 0)
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_FIRST_REPLY));
            };
        };

        if (replyMetaData.isQuickReply) { //oldRating < 0 && newRating >= 0
            if (i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getLessThan() && (i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getEual())) {
                changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_QUICK_REPLY));
            } else if ((i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getEual()) && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getLessThan()) { // oldRating >= 0 && newRating < 0
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_QUICK_REPLY));
            };
        };

        userLib::updateRating(
            voteUserCommunityRating,
            periodRewardContainer,
            voteUserId,
            changeReplyAuthorRating,
            communityId,
            ctx
        );

        vote(
            usersRatingCollection,
            periodRewardContainer,
            voteUserId,
            replyMetaData.author,
            postType,
            isUpvote,
            ratingChange,
            TYPE_CONTENT_REPLY,
            communityId,
            ctx
        );
        
        let voteDirection;
        if (isCancel) {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                voteDirection = DIRECTION_CANCEL_DOWNVOTE;
            } else {
                voteDirection = DIRECTION_CANCEL_UPVOTE;
            };
        } else {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                voteDirection = DIRECTION_UPVOTE
            } else {
                voteDirection = DIRECTION_DOWNVOTE
            };
        };
        event::emit(VoteItem{userId: voteUserId, postMetaDataId: object::id(postMetaData), replyMetaDataKey: replyMetaDataKey, commentMetaDataKey: 0, voteDirection: voteDirection});
    }

    public entry fun voteComment(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControl::UserRolesCollection,
        voteUser: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyMetaDataKey: u64,
        commentMetaDataKey: u64,
        isUpvote: bool,
    ) {
    //    E_POST_DELETED;           // test
        let voteUserId = object::id(voteUser);
        let communityId = postMetaData.communityId;
        let commentMetaData = getMutableCommentMetaDataSafe(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);   // test exist /deleted
        assert!(voteUserId != commentMetaData.author, E_ERROR_VOTE_COMMENT);   // test
        
        let (ratingChange, isCancel) = getForumItemRatingChange(voteUserId, &mut commentMetaData.historyVotes, isUpvote);
        let voteUserCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, voteUserId);
        
        userLib::checkActionRole(
            voteUser,
            voteUserCommunityRating,
            userRolesCollection,
            voteUserId,
            commentMetaData.author,
            communityId,
            if(isCancel) 
                userLib::get_action_cancel_vote() else  
                userLib::get_action_vote_comment(),
            accessControl::get_action_role_none(),
            /*false*/
        );
        commentMetaData.rating = i64Lib::add(&commentMetaData.rating, &ratingChange);

        let voteDirection;
        if (isCancel) {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                voteDirection = DIRECTION_CANCEL_DOWNVOTE;
            } else {
                voteDirection = DIRECTION_CANCEL_UPVOTE;
            };
        } else {
            if (i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                voteDirection = DIRECTION_UPVOTE;
            } else {
                voteDirection = DIRECTION_DOWNVOTE;
            };
        };

        event::emit(VoteItem{userId: voteUserId, postMetaDataId: object::id(postMetaData), replyMetaDataKey: parentReplyMetaDataKey, commentMetaDataKey: commentMetaDataKey, voteDirection: voteDirection});
    }

    fun vote(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
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

        let voteUserCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, voteUserId);
        userLib::updateRating(
            voteUserCommunityRating,
            periodRewardContainer,
            voteUserId,
            voteUserRating,
            communityId,
            ctx
        );

        let votedUserCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, votedUserId);
        userLib::updateRating(
            votedUserCommunityRating,
            periodRewardContainer,
            votedUserId,
            _authorRating,
            communityId,
            ctx
        );
    }

    fun changePostType(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        postMetaData: &mut PostMetaData,
        newPostType: u8,
        ctx: &mut TxContext
    ) {
        if (postMetaData.postType == newPostType) return;

        let oldPostType = postMetaData.postType;
        assert!(newPostType != TUTORIAL || getActiveReplyCount(postMetaData) == 0, E_ERROR_POST_TYPE);   // test

        let oldTypeRating: StructRating = getTypesRating(oldPostType);
        let newTypeRating: StructRating = getTypesRating(newPostType);

        let (positive, negative) = getHistoryInformations(postMetaData.historyVotes);
        let positiveRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.upvotedPost, &oldTypeRating.upvotedPost), &i64Lib::from(positive));
        let negativeRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.downvotedPost, &oldTypeRating.downvotedPost), &i64Lib::from(negative));
        let changePostAuthorRating = i64Lib::add(&positiveRating, &negativeRating);

        let bestReplyMetaDataKey = postMetaData.bestReplyMetaDataKey;
        let replyMetaDataKey = 1;
        let repliesCount = table::length(&postMetaData.replies);
        while(replyMetaDataKey <= repliesCount) {
            let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
            if (replyMetaData.isDeleted) {
                replyMetaDataKey = replyMetaDataKey + 1;
                continue
            };
            let (positive, negative) = getHistoryInformations(replyMetaData.historyVotes);

            positiveRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.upvotedReply, &oldTypeRating.upvotedReply), &i64Lib::from(positive));
            negativeRating = i64Lib::mul(&i64Lib::sub(&newTypeRating.downvotedReply, &oldTypeRating.downvotedReply), &i64Lib::from(negative));
            let changeReplyAuthorRating = i64Lib::add(&positiveRating, &negativeRating);

            if (i64Lib::compare(&replyMetaData.rating, &i64Lib::zero()) == i64Lib::getGreaterThan() 
                || i64Lib::compare(&replyMetaData.rating, &i64Lib::zero()) == i64Lib::getEual()) {
                if (replyMetaData.isFirstReply) {
                    changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &i64Lib::sub(&newTypeRating.firstReply, &oldTypeRating.firstReply));
                };
                if (replyMetaData.isQuickReply) {
                    changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &i64Lib::sub(&newTypeRating.quickReply, &oldTypeRating.quickReply));
                };
            };
            if (bestReplyMetaDataKey == replyMetaDataKey) {
                changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &i64Lib::sub(&newTypeRating.acceptReply, &oldTypeRating.acceptReply));
                changePostAuthorRating = i64Lib::add(&changePostAuthorRating, &i64Lib::sub(&newTypeRating.acceptedReply, &oldTypeRating.acceptedReply));
            };

            let replyAuthorCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, replyMetaData.author);
            userLib::updateRating(
                replyAuthorCommunityRating,
                periodRewardContainer,
                replyMetaData.author,
                changeReplyAuthorRating,
                postMetaData.communityId,
                ctx
            );
            replyMetaDataKey = replyMetaDataKey + 1;
        };
        let postAuthorCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, postMetaData.author);
        userLib::updateRating(
            postAuthorCommunityRating,
            periodRewardContainer,
            postMetaData.author,
            changePostAuthorRating,
            postMetaData.communityId,
            ctx
        );

        postMetaData.postType = newPostType;
    }

    fun changePostCommunity(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        periodRewardContainer: &mut userLib::PeriodRewardContainer,
        postMetaData: &mut PostMetaData,
        community: &communityLib::Community,
        ctx: &mut TxContext
    ) {
        let newCommunityId = object::id(community);
        if (postMetaData.communityId == newCommunityId) return;

        communityLib::onlyNotFrezenCommunity(community);
        let oldCommunityId: ID = postMetaData.communityId;
        let postType: u8 = postMetaData.postType;
        let typeRating: StructRating = getTypesRating(postType);

        let (positive, negative) = getHistoryInformations(postMetaData.historyVotes);
        let positiveRating = i64Lib::mul(&typeRating.upvotedPost, &i64Lib::from(positive));
        let negativeRating = i64Lib::mul(&typeRating.downvotedPost, &i64Lib::from(negative));
        let changePostAuthorRating = i64Lib::add(&positiveRating, &negativeRating);

        let bestReplyMetaDataKey = postMetaData.bestReplyMetaDataKey;
        let replyMetaDataKey = 1;
        let repliesCount = table::length(&postMetaData.replies);
        while(replyMetaDataKey <= repliesCount) {
            let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
            if (replyMetaData.isDeleted) {
                replyMetaDataKey = replyMetaDataKey + 1;
                continue
            };

            (positive, negative) = getHistoryInformations(replyMetaData.historyVotes);
            positiveRating = i64Lib::mul(&typeRating.upvotedReply, &i64Lib::from(positive));
            negativeRating = i64Lib::mul(&typeRating.downvotedReply, &i64Lib::from(negative));
            let changeReplyAuthorRating = i64Lib::add(&positiveRating, &negativeRating);
            if (i64Lib::compare(&replyMetaData.rating, &i64Lib::zero()) == i64Lib::getGreaterThan() 
                || i64Lib::compare(&replyMetaData.rating, &i64Lib::zero()) == i64Lib::getEual()) {
                if (replyMetaData.isFirstReply) {
                    changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &typeRating.firstReply);
                };
                if (replyMetaData.isQuickReply) {
                    changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &typeRating.quickReply);
                };
            };
            if (bestReplyMetaDataKey == replyMetaDataKey) {
                changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &typeRating.acceptReply);
                changePostAuthorRating = i64Lib::add(&changeReplyAuthorRating, &typeRating.acceptedReply);
            };

            let replyAuthorCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, replyMetaData.author);
            userLib::updateRating(
                replyAuthorCommunityRating,
                periodRewardContainer,
                postMetaData.author,
                i64Lib::mul(&changeReplyAuthorRating, &i64Lib::neg_from(1)),
                oldCommunityId,
                ctx
            );
            userLib::updateRating(
                replyAuthorCommunityRating,
                periodRewardContainer,
                postMetaData.author,
                changeReplyAuthorRating,
                newCommunityId,
                ctx
            );
            replyMetaDataKey = replyMetaDataKey + 1;
        };

        let postAuthorCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, postMetaData.author);
        userLib::updateRating(
            postAuthorCommunityRating,
            periodRewardContainer,
            postMetaData.author,
            i64Lib::mul(&changePostAuthorRating, &i64Lib::neg_from(1)),
            oldCommunityId,
            ctx
        );
        userLib::updateRating(
            postAuthorCommunityRating,
            periodRewardContainer,
            postMetaData.author,
            changePostAuthorRating,
            newCommunityId,
            ctx
        );
        postMetaData.communityId = newCommunityId;
    }

    ///
    // del
    ///
    // public entry fun addUserRating(
    //     usersRatingCollection: &mut userLib::UsersRatingCollection,
    //     periodRewardContainer: &mut userLib::PeriodRewardContainer,
    //     user: &mut userLib::User,
    //     community: &communityLib::Community,
    //     changeRating: u64,
    //     isPositive: bool,
    //     ctx: &mut TxContext
    // ) {
    //     let userId = object::id(user);
    //     let userCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, userId);

    //     userLib::updateRating(
    //         userCommunityRating,
    //         periodRewardContainer,
    //         userId,
    //         if(isPositive) i64Lib::from(changeRating) else i64Lib::neg_from(changeRating),
    //         object::id(community),
    //         ctx
    //     );
    // }

    fun checkMatchItemId(
        itemId: ID,
        savedItemId: ID
    ) {
        assert!(
            itemId == savedItemId,
            E_ITEM_ID_NOT_MATCHING
        ); 
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
            abort E_INVALID_POST_TYPE   // test
        }
    }

    fun getHistoryInformations(
        historyVotes: VecMap<ID, u8>
    ): (u64, u64) {
        let index = 0;
        let positive = 0;
        let negative = 0;
        let historyVotesSize = vec_map::size(&historyVotes);
        while(index < historyVotesSize) {
            let (_, value) = vec_map::get_entry_by_idx(&historyVotes, index);
            if (value == &UPVOTE) {
                positive = positive + 1;
            } else if (value == &DOWNVOTE) {
                negative = negative + 1;
            };
            index = index +1;
        };
        (positive, negative)
    }

    public fun getMutableReplyMetaData(postMetaData: &mut PostMetaData, replyMetaDataKey: u64): &mut ReplyMetaData {
        assert!(replyMetaDataKey >= 0, E_ITEM_ID_CAN_NOT_BE_0);
        assert!(table::length(&postMetaData.replies) >= replyMetaDataKey, E_REPLY_NOT_EXIST);
        let replyMetaData = table::borrow_mut<u64, ReplyMetaData>(&mut postMetaData.replies, replyMetaDataKey);
        replyMetaData
    }

    public fun getMutableReplyMetaDataSafe(postMetaData: &mut PostMetaData, replyMetaDataKey: u64): &mut ReplyMetaData {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let replyMetaData = getMutableReplyMetaData(postMetaData, replyMetaDataKey);
        assert!(!replyMetaData.isDeleted, E_REPLY_DELETED);
        replyMetaData
    }

    public fun getReplyMetaData(postMetaData: &PostMetaData, replyMetaDataKey: u64): &ReplyMetaData {
        assert!(replyMetaDataKey > 0, E_ITEM_ID_CAN_NOT_BE_0);
        assert!(table::length(&postMetaData.replies) >= replyMetaDataKey, E_REPLY_NOT_EXIST);
        let replyMetaData = table::borrow<u64, ReplyMetaData>(&postMetaData.replies, replyMetaDataKey);
        replyMetaData
    }

    public fun getReplyMetaDataSafe(postMetaData: &PostMetaData, replyMetaDataKey: u64): &ReplyMetaData {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
        assert!(!replyMetaData.isDeleted, E_REPLY_DELETED);
        replyMetaData
    }

    public fun getMutableCommentMetaData(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): &mut CommentMetaData {
        assert!(commentMetaDataKey > 0, E_ITEM_ID_CAN_NOT_BE_0);
        if (parentReplyMetaDataKey == 0) {
            assert!(table::length(&postMetaData.comments) >= commentMetaDataKey, E_COMMENT_NOT_EXIST);
            let comment = table::borrow_mut(&mut postMetaData.comments, commentMetaDataKey);
            comment

        } else {
            let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, parentReplyMetaDataKey);
            assert!(table::length(&replyMetaData.comments) >= commentMetaDataKey, E_COMMENT_NOT_EXIST);
            let commentMetaData = table::borrow_mut(&mut replyMetaData.comments, commentMetaDataKey);
            commentMetaData
        }
    }

    public fun getMutableCommentMetaDataSafe(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): &mut CommentMetaData {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let commentMetaData = getMutableCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);
        assert!(!commentMetaData.isDeleted, E_COMMENT_DELETED);
        commentMetaData
    }

    public fun getCommentMetaData(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): &CommentMetaData {
        getMutableCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey)
    }

    public fun getCommentMetaDataSafe(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): &CommentMetaData {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let commentMetaData = getCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);
        assert!(!commentMetaData.isDeleted, E_COMMENT_DELETED);
        commentMetaData
    }

    fun getActiveReplyCount(
        postMetaData: &PostMetaData
    ): u64 {
        return table::length(&postMetaData.replies) - postMetaData.deletedReplyCount
    }

    // public fun getReply(postCollection: &mut PostCollection, postId: u64, replyMetaDataKey: u64): &mut Reply {
    //     let post = getPost(postCollection, postId);
    //     return getReplyContainer(post, replyMetaDataKey)
    // }

    // public fun getComment(postCollection: &mut PostCollection, postId: u64, replyMetaDataKey: u64, commentMetaDataKey: u64): &mut Comment {
    //     let post = getPost(postCollection, postId);
    //     return getCommentContainer(post, replyMetaDataKey, commentMetaDataKey)
    // }

    #[test_only]
    public fun isDeletedPost(postMetaData: &PostMetaData): (bool) {
        postMetaData.isDeleted
    }

    #[test_only]
    public fun isDeletedReply(postMetaData: &PostMetaData, replyMetaDataKey: u64): (bool) {
        let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
        replyMetaData.isDeleted
    }

    #[test_only]
    public fun isDeletedComment(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): bool {
        let commentMetaData = getCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);
        commentMetaData.isDeleted
    }

    #[test_only]
    public fun getPostLanguage(postMetaData: &PostMetaData): u8 {
        postMetaData.language
    }

    #[test_only]
    public fun getReplyLanguage(postMetaData: &PostMetaData, replyMetaDataKey: u64): u8 {
        let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
        replyMetaData.language
    }

    #[test_only]
    public fun getCommentLanguage(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): u8 {
        let commentMetaData = getCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);
        commentMetaData.language
    }

    #[test_only]
    public fun getPostType(postMetaData: &PostMetaData): u8 {
        postMetaData.postType
    }

    #[test_only]
    public fun getPostHistoryVotes(postMetaData: &PostMetaData): VecMap<ID, u8> {
        postMetaData.historyVotes
    }

    #[test_only]
    public fun getReplyHistoryVotes(postMetaData: &PostMetaData, replyMetaDataKey: u64): VecMap<ID, u8> {
        let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
        replyMetaData.historyVotes
    }

    #[test_only]
    public fun getCommentHistoryVotes(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): VecMap<ID, u8> {
        let commentMetaData = getCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);
        commentMetaData.historyVotes
    }

    #[test_only]
    public fun getPostData(postMetaData: &PostMetaData, post: &Post): (vector<u8>, ID, u8, ID, i64Lib::I64, ID, u8, u64, u64, u64, bool, vector<u64>, VecMap<ID, u8>) {
        checkMatchItemId(object::id(post), postMetaData.postId);

        (
            commonLib::getIpfsHash(post.ipfsDoc),
            postMetaData.postId,
            postMetaData.postType,
            postMetaData.author,
            postMetaData.rating,
            postMetaData.communityId,
            postMetaData.language,
            postMetaData.officialReplyMetaDataKey,
            postMetaData.bestReplyMetaDataKey,
            postMetaData.deletedReplyCount,
            postMetaData.isDeleted,
            postMetaData.tags,
            postMetaData.historyVotes, 
        )
        // todo
        // replies: Table<u64, ReplyMetaData>,
        // comments: Table<u64, CommentMetaData>,
        // properties: VecMap<u8, vector<u8>>,
    }

    #[test_only]
    public fun getReplyData(postMetaData: &PostMetaData, reply: &Reply, replyMetaDataKey: u64): (vector<u8>, ID, ID, i64Lib::I64, u64, u8, bool, bool, bool, VecMap<ID, u8>) {
        let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
        checkMatchItemId(object::id(reply), replyMetaData.replyId);

        (
            commonLib::getIpfsHash(reply.ipfsDoc),
            replyMetaData.replyId,
            replyMetaData.author,
            replyMetaData.rating,
            replyMetaData.parentReplyMetaDataKey,
            replyMetaData.language,
            replyMetaData.isFirstReply,
            replyMetaData.isQuickReply,
            replyMetaData.isDeleted,
            replyMetaData.historyVotes,
        )
        // add
        // comments: Table<u64, CommentMetaData>,
        // properties: VecMap<u8, vector<u8>>,
    }

    #[test_only]
    public fun getCommentData(postMetaData: &mut PostMetaData, comment: &Comment, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): (vector<u8>, ID, ID, i64Lib::I64, u8, bool, VecMap<ID, u8>) {
        let commentMetaData = getCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);
        checkMatchItemId(object::id(comment), commentMetaData.commentId);

        (
            commonLib::getIpfsHash(comment.ipfsDoc),
            commentMetaData.commentId,
            commentMetaData.author,
            commentMetaData.rating,
            commentMetaData.language,
            commentMetaData.isDeleted,
            commentMetaData.historyVotes,
        )
        // add
        // properties: VecMap<u8, vector<u8>>,
    }

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
            else abort E_INVALID_RESOURCE_TYPE    // test

        } else if (postType == COMMON_POST) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_COMMON_POST)
            else abort E_INVALID_RESOURCE_TYPE    // test

        } else if (postType == TUTORIAL) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_TUTORIAL)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_TUTORIAL)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_TUTORIAL)
            else abort E_INVALID_RESOURCE_TYPE   // test

        } else {
            abort E_INVALID_POST_TYPE    // test
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
            else abort E_INVALID_RESOURCE_TYPE // test

        } else if (postType == COMMON_POST) {
            if (resourceAction == RESOURCE_ACTION_DOWNVOTE) i64Lib::neg_from(DOWNVOTE_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_UPVOTED) i64Lib::from(UPVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_DOWNVOTED) i64Lib::neg_from(DOWNVOTED_COMMON_POST)
            else if (resourceAction == RESOURCE_ACTION_ACCEPTED_REPLY) i64Lib::from(ACCEPTED_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_ACCEPT_REPLY) i64Lib::from(ACCEPT_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_FIRST_REPLY) i64Lib::from(FIRST_COMMON_REPLY)
            else if (resourceAction == RESOURCE_ACTION_QUICK_REPLY) i64Lib::from(QUICK_COMMON_REPLY)
            else abort E_INVALID_RESOURCE_TYPE // test

        } else if (postType == TUTORIAL) {
            i64Lib::zero()

        } else {
            abort E_INVALID_RESOURCE_TYPE // test
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
    // 1 - downVote
    // 2 - cancelVote       // todo? cancelVote - 0? delete vote if cancel + delete from votedUsers
    // 3 - upvote
    ///
    public fun getForumItemRatingChange(
        userId: ID,
        historyVotes: &mut VecMap<ID, u8>,
        isUpvote: bool,
    ): (i64Lib::I64, bool) {
        let (history, isExistVote) = getHistoryVote(userId, *historyVotes);
        let ratingChange: i64Lib::I64;
        let isCancel: bool = false;
        
        if (isUpvote) {
            if (history == DOWNVOTE) {
                let userHistoryVote = vec_map::get_mut(historyVotes, &userId);
                *userHistoryVote = UPVOTE;
                ratingChange = i64Lib::from(2);
            } else if (history == NONE_VOTE) {
                if (isExistVote) {
                   let userHistoryVote = vec_map::get_mut(historyVotes, &userId);
                    *userHistoryVote = UPVOTE;
                } else {
                    vec_map::insert(historyVotes, userId, UPVOTE);
                };
                ratingChange = i64Lib::from(1);
            } else {
                let userHistoryVote = vec_map::get_mut(historyVotes, &userId);
                *userHistoryVote = NONE_VOTE;
                ratingChange = i64Lib::neg_from(1);
                isCancel = true;
            };
        } else {
            if (history == DOWNVOTE) {
                let userHistoryVote = vec_map::get_mut(historyVotes, &userId);
                *userHistoryVote = NONE_VOTE;
                ratingChange = i64Lib::from(1);
                isCancel = true;
            } else if (history == NONE_VOTE) {
                if (isExistVote) {
                    let userHistoryVote = vec_map::get_mut(historyVotes, &userId);
                    *userHistoryVote = DOWNVOTE;
                } else {
                    vec_map::insert(historyVotes, userId, DOWNVOTE);
                };
                ratingChange = i64Lib::neg_from(1);
            } else {
                let userHistoryVote = vec_map::get_mut(historyVotes, &userId);
                *userHistoryVote = DOWNVOTE;
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
        historyVotes: VecMap<ID, u8>,
    ): (u8, bool) { // (status vote, isExistVote)
        let isExist = vec_map::contains(&historyVotes, &userId);

        if (isExist) {
            let voteValue = vec_map::get(&historyVotes, &userId);
            (*voteValue, true)
        } else {
            (NONE_VOTE, false)
        }
    }
}
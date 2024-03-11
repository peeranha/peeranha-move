module peeranha::postLib {    
    use sui::transfer;
    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::clock::{Clock};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use std::vector;
    use peeranha::accessControlLib;
    use peeranha::communityLib;
    use peeranha::commonLib;
    use peeranha::userLib;
    use peeranha::i64Lib;
    use peeranha::nftLib;
    use sui::table::{Self, Table};

    // ====== Errors. Available values 100 - 199 ======

    const E_INVALID_POST_TYPE: u64 = 100;

    const E_INVALID_RESOURCE_TYPE: u64 = 101;

    const E_ITEM_ID_CAN_NOT_BE_0: u64 = 102;

    const E_USER_CAN_NOT_PUBLISH_2_REPLIES_FOR_POST: u64 = 103;

    const E_NOT_ALLOWED_EDIT_NOT_AUTHOR: u64 = 104;

    const E_YOU_CAN_NOT_DELETE_THE_BEST_REPLY: u64 = 105;

    const E_YOU_CAN_NOT_PUBLISH_REPLIES_IN_TUTORIAL: u64 = 106;

    const E_USER_IS_FORBIDDEN_TO_REPLY_ON_REPLY_FOR_EXPERT_AND_COMMON_TYPE_OF_POST: u64 = 107;       // name

    const E_THIS_POST_TYPE_IS_ALREADY_SET: u64 = 108;        // deleted

    const E_ERROR_POST_TYPE: u64 = 109;      ///

    const E_ERROR_VOTE_COMMENT: u64 = 110;

    const E_ERROR_VOTE_REPLY: u64 = 111;

    const E_ERROR_VOTE_POST: u64 = 112;

    const E_POST_NOT_EXIST: u64 = 113;

    const E_REPLY_NOT_EXIST: u64 = 114;

    const E_COMMENT_NOT_EXIST: u64 = 115;

    const E_POST_DELETED: u64 = 116;

    const E_REPLY_DELETED: u64 = 117;

    const E_COMMENT_DELETED: u64 = 118;

    const E_ERROR_CHANGE_COMMUNITY_ID: u64 = 119;

    const E_ONLY_OWNER_BY_POST_CAN_CHANGE_STATUS_BEST_REPLY: u64 = 120;

    const E_WRONG_SIGNER: u64 = 121;

    const E_ITEM_ID_NOT_MATCHING: u64 = 122;

    const E_AT_LEAST_ONE_TAG_IS_REQUIRED: u64 = 123;

    const E_INVALID_LANGUAGE: u64 = 124;

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

    const MESSENGER_TYPE_UNKNOWN: u8 = 0;
    const MESSENGER_TYPE_TELEGRAM: u8 = 1;
    const MESSENGER_TYPE_DISCORD: u8 = 2;
    const MESSENGER_TYPE_SLACK: u8 = 3;

    struct Post has key {
        id: UID,
        /// `IPFS hash` of document with `post` information
        ipfsDoc: commonLib::IpfsHash,
        /// Properties for the `post`
        properties: VecMap<u8, vector<u8>>,
    }

    struct PostMetaData has key {       // shared
        id: UID,
        /// `Post object id` for the `post meta data`
        postId: ID,
        /// `Post type` of the `post meta data`
        postType: u8,
        /// `Created time` of the `post meta data`
        postTime: u64,
        /// `Author` of the `post meta data`
        author: ID,
        /// Information the `post author` when create `bot`
        /// Defaut value - vector::empty<u8>()
        /// For bot - messenger `type` + `handle`
        authorMetaData: vector<u8>,
        /// `Rating` of the `post meta data`
        rating: i64Lib::I64,
        /// `Community Id` for the `post meta data`
        communityId: ID,
        /// Current `language` for the `post meta data`
        language: u8,

        /// `Oficial reply meta data key` in `replies` for the `post meta data`
        officialReplyMetaDataKey: u64,
        /// `Best reply meta data key` in replies for the `post meta data`
        bestReplyMetaDataKey: u64,
        /// Deleted `reply` count 
        deletedRepliesCount: u64,
        /// Status of the `post meta data`
        isDeleted: bool,

        /// `Tags key` in `Community->tags` for the `post meta data`
        tags: vector<u64>,
        /// `Replies meta data` for the `post meta data`. Table key - `reply meta data key`
        replies: Table<u64, ReplyMetaData>,
        /// `Comments meta data` for the `post meta data`. Table key - `comment meta data key`
        comments: Table<u64, CommentMetaData>,
        /// Properties for the `post meta data`
        properties: VecMap<u8, vector<u8>>,
        /// Users vote for the `post meta data`. VecMap key - `user object id`. downVote = 1, NONE = 2, upVote = 3.
        historyVotes: VecMap<ID, u8>,      // rewrite look getForumItemRatingChange
    }

    struct Reply has key {
        id: UID,
        /// `IPFS hash` of document with `reply` information
        ipfsDoc: commonLib::IpfsHash,
        /// Properties for the `reply`
        properties: VecMap<u8, vector<u8>>,
    }

    struct ReplyMetaData has key, store {
        id: UID,
        /// `Reply object id` for the `reply meta data`
        replyId: ID,
        /// `Created time` of the `reply meta data`
        postTime: u64,
        /// `Author` of the `reply meta data`
        author: ID,
        /// Information the `post author` when create bot
        /// Defaut value - vector::empty<u8>()
        /// For bot - messenger `type` + `handle`
        authorMetaData: vector<u8>,
        /// `Rating` of the `reply meta data`
        rating: i64Lib::I64,
        /// `Parent reply meta data key` for the `reply meta data` (reply to reply).
        parentReplyMetaDataKey: u64,
        /// Current `language` for the `reply meta data`
        language: u8,

        /// Status of the `reply meta data`. First for `post`
        isFirstReply: bool,
        /// Status of the `reply meta data`. The `reply` created less than 15 minutes after created `post`.
        isQuickReply: bool,
        /// Status of the `reply meta data`
        isDeleted: bool,

        /// `Comments meta data` for the `reply meta data`. Table key - `comment meta data key`
        comments: Table<u64, CommentMetaData>,
        /// Properties for the `reply meta data`
        properties: VecMap<u8, vector<u8>>,
        /// Users' Vote for the `reply meta data`. VecMap key - user object id. downVote = 1, NONE = 2, upVote = 3.
        historyVotes: VecMap<ID, u8>,       // rewrite look getForumItemRatingChange
    }

    struct Comment has key {
        id: UID,
        /// `IPFS hash` of document with `comment` information
        ipfsDoc: commonLib::IpfsHash,
        /// `Properties` for the `comment`
        properties: VecMap<u8, vector<u8>>,
    }

    struct CommentMetaData has key, store {
        id: UID,
        /// `Comment object id` for the `comment meta data`
        commentId: ID,
        /// `Created time` of the `comment meta data`
        postTime: u64,
        /// `Author` of the `comment meta data`
        author: ID,
        /// `Rating` of the `comment meta data`
        rating: i64Lib::I64,
        /// Current `language` for the `comment meta data`
        language: u8,

        /// Status of the `comment meta data`
        isDeleted: bool,
        /// `Properties` for the `comment meta data`
        properties: VecMap<u8, vector<u8>>,
        /// `Users' Vote for the `comment meta data`. VecMap key - `user object id`. downVote = 1, NONE = 2, upVote = 3.
        historyVotes: VecMap<ID, u8>,       // rewrite look getForumItemRatingChange
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

    struct PostTypeChanged has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        oldPostType: u8,
    }

    struct PostCommunityChanged has copy, drop {
        userId: ID,
        postMetaDataId: ID,
        oldCommunityId: ID,
    }

    /// Publication `post` by `bot`
    public entry fun createPostByBot(
        roles: &mut accessControlLib::UserRolesCollection,
        time: &Clock,
        user: &mut userLib::User,
        community: &communityLib::Community,
        ipfsHash: vector<u8>, 
        postType: u8,
        tags: vector<u64>,
        language: u8,
        messengerType: u8,
        handle: vector<u8>,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_bot(), commonLib::getZeroId());

        createPostPrivate(
            time,
            commonLib::get_bot_id(),
            community,
            ipfsHash, 
            postType,
            tags,
            language,
            commonLib::compose_messenger_sender_property(messengerType, handle),
            ctx
        )
    }

    /// Publication `post` by `user`
    public entry fun createPost(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
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

        let communityId = object::id(community);
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            user,
            userId,
            communityId,
            userLib::get_action_publication_post(),
            accessControlLib::get_action_role_none(),
        );

        createPostPrivate(
            time,
            userId,
            community,
            ipfsHash, 
            postType,
            tags,
            language,
            vector::empty<u8>(),
            ctx
        )
    }

    /// Publication `post`
    fun createPostPrivate(
        time: &Clock,
        userId: ID,
        community: &communityLib::Community,
        ipfsHash: vector<u8>, 
        postType: u8,
        tags: vector<u64>,
        language: u8,
        authorMetaData: vector<u8>,
        ctx: &mut TxContext
    ) {
        communityLib::onlyNotFrozenCommunity(community);
        communityLib::checkTags(community, tags);
        let communityId = object::id(community);

        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);

        assert!(vector::length(&mut tags) > 0, E_AT_LEAST_ONE_TAG_IS_REQUIRED);
        let postTags = tags;

        let post = Post {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            properties: vec_map::empty(),
        };
        let postMetaData = PostMetaData {
            id: object::new(ctx),
            postId: object::id(&post),
            postType: postType,
            postTime: commonLib::getTimestamp(time),
            author: userId,
            authorMetaData: authorMetaData,
            rating: i64Lib::zero(),
            communityId: communityId,
            officialReplyMetaDataKey: 0,
            bestReplyMetaDataKey: 0,
            deletedRepliesCount: 0,
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

    /// Publication `reply` by `bot`
    public entry fun createReplyByBot(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        roles: &mut accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        time: &Clock,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyMetaDataKey: u64,
        ipfsHash: vector<u8>,
        language: u8,
        messengerType: u8,
        handle: vector<u8>,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_bot(), commonLib::getZeroId());

        createReplyPrivate(
            usersRatingCollection,
            achievementCollection,
            time,
            commonLib::get_bot_id(),
            postMetaData,
            parentReplyMetaDataKey,
            ipfsHash,
            false,
            language,
            commonLib::compose_messenger_sender_property(messengerType, handle),
            ctx
        )
    }

    /// Publication `reply` by `user`
    public entry fun createReply(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        time: &Clock,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyMetaDataKey: u64,
        ipfsHash: vector<u8>,
        isOfficialReply: bool,
        language: u8,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);

        let communityId = postMetaData.communityId;
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            user,
            postMetaData.author,
            communityId,
            userLib::get_action_publication_reply(),
            if (isOfficialReply)
                accessControlLib::get_action_role_community_admin() else
                accessControlLib::get_action_role_none()
        );

        createReplyPrivate(
            usersRatingCollection,
            achievementCollection,
            time,
            userId,
            postMetaData,
            parentReplyMetaDataKey,
            ipfsHash,
            isOfficialReply,
            language,
            vector::empty<u8>(),
            ctx
        )
    }

    /// Publication `reply` by `user`
    fun createReplyPrivate(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        time: &Clock,
        userId: ID,
        postMetaData: &mut PostMetaData,
        parentReplyMetaDataKey: u64,
        ipfsHash: vector<u8>,
        isOfficialReply: bool,
        language: u8,
        authorMetaData: vector<u8>,
        ctx: &mut TxContext
    ) {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        assert!(postMetaData.postType != TUTORIAL, E_YOU_CAN_NOT_PUBLISH_REPLIES_IN_TUTORIAL);
        assert!(parentReplyMetaDataKey == 0, E_USER_IS_FORBIDDEN_TO_REPLY_ON_REPLY_FOR_EXPERT_AND_COMMON_TYPE_OF_POST);
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);

        let countReplies = table::length(&postMetaData.replies);
        if (postMetaData.postType == EXPERT_POST || postMetaData.postType == COMMON_POST) {
            let replyMetaDataKey = 1;
            while (replyMetaDataKey <= countReplies) {
                let replyContainer = getReplyMetaData(postMetaData, replyMetaDataKey);
                assert!(
                    (userId != replyContainer.author && userId != commonLib::get_bot_id()) ||
                    replyContainer.authorMetaData != authorMetaData ||
                    replyContainer.isDeleted,
                    E_USER_CAN_NOT_PUBLISH_2_REPLIES_FOR_POST
                );
                replyMetaDataKey = replyMetaDataKey + 1;
            };
        };

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
                usersRatingCollection,
                userId,
                achievementCollection,
                changeUserRating,
                postMetaData.communityId,
                ctx,
            );
        };

        let reply = Reply {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            properties: vec_map::empty(),
        };
        let replyMetaData = ReplyMetaData {
            id: object::new(ctx),
            replyId: object::id(&reply),
            postTime: timestamp,
            author: userId,
            authorMetaData: authorMetaData,
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

    /// Publication `comment`
    public entry fun createComment(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        time: &Clock,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyMetaDataKey: u64,
        ipfsHash: vector<u8>,
        language: u8,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);

        let comment = Comment {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            properties: vec_map::empty(),
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
            // allow user create comment to own reply and create comment to stranger reply in own post without check rating
            if (dataUser != userId) {
                dataUser = replyMetaData.author;
            };
            commentMetaDataKey = table::length(&replyMetaData.comments) + 1;
            table::add(&mut replyMetaData.comments, commentMetaDataKey, commentMetaData);
        };

        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            user,
            dataUser,
            postMetaData.communityId,
            userLib::get_action_publication_comment(),
            accessControlLib::get_action_role_none(),
        );

        transfer::transfer(
            comment,
            tx_context::sender(ctx)
        );

        event::emit(CreateCommentEvent{userId: userId, postMetaDataId: object::id(postMetaData), parentReplyKey: parentReplyMetaDataKey, commentMetaDataKey: commentMetaDataKey});
    }

    /// `Author` edit own `post`
    public entry fun authorEditPost(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        user: &mut userLib::User,
        post: &mut Post,
        postMetaData: &mut PostMetaData,
        newCommunity: &communityLib::Community,
        ipfsHash: vector<u8>, 
        newPostType: u8,
        tags: vector<u64>,
        language: u8,
        ctx: &mut TxContext,
    ) {
        checkMatchItemId(object::id(post), postMetaData.postId);
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        if(commonLib::getIpfsHash(post.ipfsDoc) != ipfsHash)
            post.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        editPost(
            usersRatingCollection,
            userRolesCollection,
            achievementCollection,
            user,
            postMetaData,
            newCommunity,
            newPostType,
            tags,
            language,
            ctx,
        );
        event::emit(EditPostEvent{userId: object::id(user), postMetaDataId: object::id(postMetaData)});
    }

    /// `Moderator` edit `post meta data` (post type/community/tags/language)
    public entry fun moderatorEditPostMetaData(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        newCommunity: &communityLib::Community,
        newPostType: u8,
        tags: vector<u64>,
        language: u8,
        ctx: &mut TxContext,
    ) {
        // let newCommunityId = object::id(newCommunity);
        // if (newCommunityId != postMetaData.communityId /*&& newCommunityId != DEFAULT_COMMUNITY *//*&& !self.peeranhaUser.isProtocolAdmin(userAddr)*/) // todo new transfer 
        //     abort E_ERROR_CHANGE_COMMUNITY_ID;  // test

        editPost(
            usersRatingCollection,
            userRolesCollection,
            achievementCollection,
            user,
            postMetaData,
            newCommunity,
            newPostType,
            tags,
            language,
            ctx,
        );
        event::emit(ModeratorEditPostEvent{userId: object::id(user), postMetaDataId: object::id(postMetaData)});
    }

    /// Edit the `post`
    fun editPost(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        newCommunity: &communityLib::Community,
        newPostType: u8,
        tags: vector<u64>,
        language: u8,
        ctx: &mut TxContext,
    ) {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let userId = object::id(user);

        let postMetaDataAuthor = postMetaData.author;
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            user,
            postMetaDataAuthor,
            postMetaData.communityId,
            if (userId == postMetaDataAuthor)
                userLib::get_action_edit_item() else
                userLib::get_action_none(),
            if (userId == postMetaDataAuthor)
                accessControlLib::get_action_role_none() else
                accessControlLib::get_action_role_admin_or_community_moderator(),
        );

        if (postMetaData.postType != newPostType) {
            event::emit(PostTypeChanged{userId: userId, postMetaDataId: object::id(postMetaData), oldPostType: postMetaData.postType});
            changePostType(usersRatingCollection, achievementCollection, postMetaData, newPostType, ctx);
        };
        if (postMetaData.communityId != object::id(newCommunity)) {
            event::emit(PostCommunityChanged{userId: userId, postMetaDataId: object::id(postMetaData), oldCommunityId: postMetaData.communityId});
            changePostCommunity(usersRatingCollection, achievementCollection, postMetaData, newCommunity, ctx);
        };

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

    /// `Author` edit own `reply`
    public entry fun authorEditReply(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        reply: &mut Reply,
        replyMetaDataKey: u64,
        ipfsHash: vector<u8>, 
        isOfficialReply: bool,
        language: u8,
    ) {
        let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, replyMetaDataKey);
        checkMatchItemId(object::id(reply), replyMetaData.replyId);
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

    // moderatorEditReply -> moderatorEditReplyMetaData
    /// `Moderator` edit `reply`(isOfficialReply/language)
    public entry fun moderatorEditReply(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
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

    /// Edit `reply`
    fun editReply(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        replyMetaDataKey: u64,
        isOfficialReply: bool,
        language: u8,
    ) {
        let userId = object::id(user);
        let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, replyMetaDataKey);

        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);
        if (replyMetaData.language != language) {
            replyMetaData.language = language;
        };

        let replyMetaDataAuthor = replyMetaData.author;
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            user,
            replyMetaDataAuthor,
            postMetaData.communityId,
            if (userId == replyMetaDataAuthor)
                userLib::get_action_edit_item() else
                userLib::get_action_none(),
            if (isOfficialReply || userId != replyMetaDataAuthor)
                accessControlLib::get_action_role_community_admin()else
                accessControlLib::get_action_role_none(),
        );

        if (isOfficialReply) {
            postMetaData.officialReplyMetaDataKey = replyMetaDataKey;
        } else if (postMetaData.officialReplyMetaDataKey == replyMetaDataKey) {
            postMetaData.officialReplyMetaDataKey = 0;
        };
    }

    /// `Author` edit `comment`
    public entry fun editComment(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        comment: &mut Comment,
        parentReplyKey: u64,
        commentMetaDataKey: u64,
        ipfsHash: vector<u8>,
        language: u8,
    ) {
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash());
        let commentMetaData = getMutableCommentMetaDataSafe(postMetaData, parentReplyKey, commentMetaDataKey);
        checkMatchItemId(object::id(comment), commentMetaData.commentId);

        assert!(language < LANGUAGE_LENGTH, E_INVALID_LANGUAGE);
        if (commentMetaData.language != language) {
            commentMetaData.language = language;
        };

        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            user,
            commentMetaData.author,
            postMetaData.communityId,
            userLib::get_action_edit_item(),
            accessControlLib::get_action_role_none(),
        );

        if (commonLib::getIpfsHash(comment.ipfsDoc) != ipfsHash)
            comment.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());

        event::emit(EditCommentEvent{userId: object::id(user), postMetaDataId: object::id(postMetaData), parentReplyKey: parentReplyKey, commentMetaDataKey: commentMetaDataKey});
    }

    /// `Author` and `moderator` delete `post`
    public entry fun deletePost(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        time: &Clock,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        ctx: &mut TxContext,
    ) {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let communityId = postMetaData.communityId;
        let postAuthor = postMetaData.author;
        let bestReplyMetaDataKey = postMetaData.bestReplyMetaDataKey;
        let userId = object::id(user);
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            user,
            postAuthor,
            communityId,
            userLib::get_action_delete_item(),
            accessControlLib::get_action_role_none(),
        );

        let postType = postMetaData.postType;
        let currentTime: u64 = commonLib::getTimestamp(time);
        let changeUserRating: i64Lib::I64 = i64Lib::zero();
        if (currentTime - postMetaData.postTime < DELETE_TIME || userId == postAuthor) {
            let typeRating: StructRating = getTypesRating(postType);

            let (positive, negative) = getHistoryInformations(postMetaData.historyVotes);
            let changeVoteUserRating: i64Lib::I64 = i64Lib::add(&i64Lib::mul(&typeRating.upvotedPost, &i64Lib::from(positive)), &i64Lib::mul(&typeRating.downvotedPost, &i64Lib::from(negative)));
            if (i64Lib::compare(&changeVoteUserRating, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                changeUserRating = i64Lib::sub(&changeUserRating, &changeVoteUserRating);
            };
        };
        if (bestReplyMetaDataKey != 0) {
            changeUserRating = i64Lib::sub(&changeUserRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPT_REPLY));
        };

        changeUserRating = i64Lib::sub(&changeUserRating, if(userId == postAuthor)
            &i64Lib::from(DELETE_OWN_POST) else
            &i64Lib::from(MODERATOR_DELETE_POST));
        userLib::updateRating(
            usersRatingCollection,
            postMetaData.author,
            achievementCollection,
            changeUserRating,
            communityId,
            ctx,
        );

        if (currentTime - postMetaData.postTime < DELETE_TIME) {
            let replyCount = table::length(&postMetaData.replies);
            let replyMetaDataKey = 1;

            while (replyMetaDataKey <= replyCount) {
                let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
                deductReplyRating(
                    usersRatingCollection,
                    achievementCollection,
                    replyMetaData,
                    postType,
                    bestReplyMetaDataKey == replyMetaDataKey,
                    communityId,
                    ctx,
                );
                replyMetaDataKey = replyMetaDataKey + 1;
            }
        };

        postMetaData.isDeleted = true;
        event::emit(DeletePostEvent{userId: userId, postMetaDataId: object::id(postMetaData)});
    }

    /// `Author` and `moderator` delete `reply`
    public entry fun deleteReply(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        time: &Clock,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        replyMetaDataKey: u64,
        ctx: &mut TxContext,
    ) {
        let userId = object::id(user);
        let communityId = postMetaData.communityId;
        
        postMetaData.deletedRepliesCount = postMetaData.deletedRepliesCount + 1;
        let isBestReplyMetaData = postMetaData.bestReplyMetaDataKey == replyMetaDataKey;
        if (isBestReplyMetaData) {
            postMetaData.bestReplyMetaDataKey = 0;
        };

        if (postMetaData.officialReplyMetaDataKey == replyMetaDataKey)
            postMetaData.officialReplyMetaDataKey = 0;
        let postType = postMetaData.postType;
        
        let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, replyMetaDataKey);
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            user,
            replyMetaData.author,
            communityId,
            userLib::get_action_delete_item(),
            accessControlLib::get_action_role_none(),
        );
        
        let time: u64 = commonLib::getTimestamp(time);
        userLib::updateRating(
            usersRatingCollection,
            replyMetaData.author,
            achievementCollection,
            if(userId == replyMetaData.author) 
                i64Lib::neg_from(DELETE_OWN_REPLY) else 
                i64Lib::neg_from(MODERATOR_DELETE_REPLY),
            communityId,
            ctx,
        );
        
        let parentReplyMetaDataKey = replyMetaData.parentReplyMetaDataKey;
        let isDeductReplyRating = time - replyMetaData.postTime < DELETE_TIME || userId == replyMetaData.author;
        if (isDeductReplyRating) {
            deductReplyRating(
                usersRatingCollection,
                achievementCollection,
                replyMetaData,
                postType,
                parentReplyMetaDataKey == 0 && isBestReplyMetaData,
                communityId,
                ctx,
            );
        };
        replyMetaData.isDeleted = true;
        event::emit(DeleteReplyEvent{userId: object::id(user), postMetaDataId: object::id(postMetaData), replyMetaDataKey: replyMetaDataKey});
    }


    /// When delete the `reply` take `rating` from the `author`
    fun deductReplyRating(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        replyMetaData: &ReplyMetaData,
        postType: u8,
        isBestReply: bool,
        communityId: ID,
        ctx: &mut TxContext,
    ) {
        if (replyMetaData.isDeleted)    // test rating
            return;

        let changeReplyAuthorRating: i64Lib::I64 = i64Lib::zero();
        if (i64Lib::compare(&replyMetaData.rating, &i64Lib::zero()) == i64Lib::getGreaterThan() || i64Lib::compare(&replyMetaData.rating, &i64Lib::zero()) == i64Lib::getEual()) {  //reply.rating >= 0
            if (replyMetaData.isFirstReply) {// -=? in solidity "+= -"
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_FIRST_REPLY));
            };
            if (replyMetaData.isQuickReply) {// -=? in solidity "+= -"
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_QUICK_REPLY));
            };
            if (isBestReply && postType != TUTORIAL) {// -=? in solidity "+= -"
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPTED_REPLY));
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
                usersRatingCollection,
                replyMetaData.author,
                achievementCollection,
                changeReplyAuthorRating,
                communityId,
                ctx,
            );
        };
    }

    /// `Author` and `moderator` delete `comment`
    public entry fun deleteComment(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        user: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyKey: u64,
        commentMetaDataKey: u64,
        ctx: &mut TxContext,
    ) {
        let userId = object::id(user);
        let communityId = postMetaData.communityId;
        let commentMetaData = getMutableCommentMetaDataSafe(postMetaData, parentReplyKey, commentMetaDataKey);
        
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            user,
            commentMetaData.author,
            communityId,
            userLib::get_action_delete_item(),
            accessControlLib::get_action_role_none(),
        );

        if (userId != commentMetaData.author) {
            userLib::updateRating(
                usersRatingCollection,
                userId,
                achievementCollection,
                i64Lib::neg_from(MODERATOR_DELETE_COMMENT),
                communityId,
                ctx,
            );
        };

        commentMetaData.isDeleted = true;
        event::emit(DeleteCommentEvent{userId: userId, postMetaDataId: object::id(postMetaData), parentReplyKey: parentReplyKey, commentMetaDataKey: commentMetaDataKey});
    }

    /// Change status `best reply`
    public entry fun changeStatusBestReply(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        postAuthor: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        newBestReplyMetaDataKey: u64,
        ctx: &mut TxContext,
    ) {
        let newBestReplyMetaData = getReplyMetaDataSafe(postMetaData, newBestReplyMetaDataKey);
        let communityId = postMetaData.communityId;
        let postAuthorId = object::id(postAuthor);
        assert!(postMetaData.author == postAuthorId, E_ONLY_OWNER_BY_POST_CAN_CHANGE_STATUS_BEST_REPLY);

        if (postMetaData.bestReplyMetaDataKey == newBestReplyMetaDataKey) {
            updateRatingForBestReply(
                usersRatingCollection,
                achievementCollection,
                postAuthorId,
                newBestReplyMetaData.author,
                postMetaData.postType,
                false,
                communityId,
                ctx,
            );
            postMetaData.bestReplyMetaDataKey = 0;
        } else {
            if (postMetaData.bestReplyMetaDataKey != 0) {
                let bestReplyMetaDataKey = postMetaData.bestReplyMetaDataKey;
                let oldBestReplyMetaData = getReplyMetaDataSafe(postMetaData, bestReplyMetaDataKey);
                updateRatingForBestReply(
                    usersRatingCollection,
                    achievementCollection,
                    postAuthorId,
                    oldBestReplyMetaData.author,
                    postMetaData.postType,
                    false,
                    communityId,
                    ctx,
                );
            };

            updateRatingForBestReply(
                usersRatingCollection,
                achievementCollection,
                postAuthorId,
                newBestReplyMetaData.author,
                postMetaData.postType,
                true,
                communityId,
                ctx,
            );
            postMetaData.bestReplyMetaDataKey = newBestReplyMetaDataKey;
        };
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            postAuthor,
            postAuthorId,
            communityId,
            userLib::get_action_best_reply(),
            accessControlLib::get_action_role_none(),
        );

        event::emit(ChangeStatusBestReply{userId: object::id(postAuthor), postMetaDataId: object::id(postMetaData), replyMetaDataKey: newBestReplyMetaDataKey});
    }

    
    /// Recalculation `post author` and `reply author` `rating` when change `status best reply`
    fun updateRatingForBestReply(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        postAuthorAddress: ID,
        replyAuthorAddress: ID,
        postType: u8,
        isMark: bool,
        communityId: ID,
        ctx: &mut TxContext,
    ) {
        if (postAuthorAddress != replyAuthorAddress) {
            userLib::updateRating(
                usersRatingCollection,
                postAuthorAddress,
                achievementCollection,
                if (isMark)
                    getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPT_REPLY) else
                    i64Lib::mul(&getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPT_REPLY), &i64Lib::neg_from(1)),
                communityId,
                ctx,
            );

            userLib::updateRating(
                usersRatingCollection,
                replyAuthorAddress,
                achievementCollection,
                if (isMark)
                    getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPTED_REPLY) else
                    i64Lib::mul(&getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_ACCEPTED_REPLY), &i64Lib::neg_from(1)),
                communityId,
                ctx,
            );
        }
    }

    /// Vote for `post`
    public entry fun votePost(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        voteUser: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        isUpvote: bool,
        ctx: &mut TxContext,
    ) {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let postType = postMetaData.postType;
        let voteUserId = object::id(voteUser);
        let communityId = postMetaData.communityId;
        assert!(voteUserId != postMetaData.author, E_ERROR_VOTE_POST);
        
        let (ratingChange, isCancel) = getForumItemRatingChange(voteUserId, &mut postMetaData.historyVotes, isUpvote);
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            voteUser,
            postMetaData.author,
            communityId,
            if(isCancel) 
                userLib::get_action_cancel_vote() else 
                    if(i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) 
                        userLib::get_action_upvote_post() else 
                        userLib::get_action_downvote_post(),
            accessControlLib::get_action_role_none(),
        );

        vote(
            usersRatingCollection,
            achievementCollection,
            voteUserId,
            postMetaData.author,
            postType,
            isUpvote,
            ratingChange,
            TYPE_CONTENT_POST,
            communityId,
            ctx,
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

    /// Vote for `reply`
    public entry fun voteReply(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        voteUser: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        replyMetaDataKey: u64,
        isUpvote: bool,
        ctx: &mut TxContext,
    ) {
        let postType = postMetaData.postType;
        let voteUserId = object::id(voteUser);
        let communityId = postMetaData.communityId;
        let replyMetaData = getMutableReplyMetaDataSafe(postMetaData, replyMetaDataKey); // test deleted post + exist/deleted reply
        assert!(voteUserId != replyMetaData.author, E_ERROR_VOTE_REPLY);

        let (ratingChange, isCancel) = getForumItemRatingChange(voteUserId, &mut replyMetaData.historyVotes, isUpvote);
        // let voteUserCommunityRating = userLib::getMutableUserCommunityRating(usersRatingCollection, voteUserId);
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            voteUser,
            replyMetaData.author,
            communityId,
            if(isCancel) 
                userLib::get_action_cancel_vote() else 
                    if(i64Lib::compare(&ratingChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) 
                        userLib::get_action_upvote_reply() else 
                        userLib::get_action_downvote_reply(),
            accessControlLib::get_action_role_none(),
        );

        let oldRating: i64Lib::I64 = replyMetaData.rating;
        replyMetaData.rating = i64Lib::add(&replyMetaData.rating, &ratingChange);
        let newRating: i64Lib::I64 = replyMetaData.rating;

        let changeReplyAuthorRating: i64Lib::I64 = i64Lib::zero();
        if (replyMetaData.isFirstReply) {  // oldRating < 0 && newRating >= 0
            if (i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getLessThan() && (i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getGreaterThan() || i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getEual())) {
                changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_FIRST_REPLY));
            } else if ((i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getGreaterThan() || i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getEual()) && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getLessThan()) { // (oldRating >= 0 && newRating < 0)
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_FIRST_REPLY));
            };
        };

        if (replyMetaData.isQuickReply) { //oldRating < 0 && newRating >= 0
            if (i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getLessThan() && (i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getGreaterThan() || i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getEual())) {
                changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_QUICK_REPLY));
            } else if ((i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getGreaterThan() || i64Lib::compare(&oldRating, &i64Lib::zero()) == i64Lib::getEual()) && i64Lib::compare(&newRating, &i64Lib::zero()) == i64Lib::getLessThan()) { // oldRating >= 0 && newRating < 0
                changeReplyAuthorRating = i64Lib::sub(&changeReplyAuthorRating, &getUserRatingChangeForReplyAction(postType, RESOURCE_ACTION_QUICK_REPLY));
            };
        };

        userLib::updateRating(
            usersRatingCollection,
            replyMetaData.author,
            achievementCollection,
            changeReplyAuthorRating,
            communityId,
            ctx,
        );

        vote(
            usersRatingCollection,
            achievementCollection,
            voteUserId,
            replyMetaData.author,
            postType,
            isUpvote,
            ratingChange,
            TYPE_CONTENT_REPLY,
            communityId,
            ctx,
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

    /// Vote for `comment`
    public entry fun voteComment(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        voteUser: &mut userLib::User,
        postMetaData: &mut PostMetaData,
        parentReplyMetaDataKey: u64,
        commentMetaDataKey: u64,
        isUpvote: bool,
    ) {
    //    E_POST_DELETED;           // test
        let voteUserId = object::id(voteUser);
        let communityId = postMetaData.communityId;
        let commentMetaData = getMutableCommentMetaDataSafe(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);   // test deleted post  exist/deleted reply
        assert!(voteUserId != commentMetaData.author, E_ERROR_VOTE_COMMENT);   // test
        
        let (ratingChange, isCancel) = getForumItemRatingChange(voteUserId, &mut commentMetaData.historyVotes, isUpvote);
        
        userLib::checkActionRole(
            usersRatingCollection,
            userRolesCollection,
            voteUser,
            commentMetaData.author,
            communityId,
            if(isCancel) 
                userLib::get_action_cancel_vote() else  
                userLib::get_action_vote_comment(),
            accessControlLib::get_action_role_none(),
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

    /// Recalculation `users' rating` after voting per a `reply` or `post`
    fun vote(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        voteUserId: ID,
        votedUserId: ID,
        postType: u8,
        isUpvote: bool,
        ratingChanged: i64Lib::I64,
        typeContent: u8,
        communityId: ID,
        ctx: &mut TxContext,
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

        userLib::updateRating(
            usersRatingCollection,
            voteUserId,
            achievementCollection,
            voteUserRating,
            communityId,
            ctx,
        );

        userLib::updateRating(
            usersRatingCollection,
            votedUserId,
            achievementCollection,
            _authorRating,
            communityId,
            ctx,
        );
    }

    /// Change `postType` for the `post` and recalculation `rating` for all `users` who were active in the `post`
    fun changePostType(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        postMetaData: &mut PostMetaData,
        newPostType: u8,
        ctx: &mut TxContext,
    ) {
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
            if (bestReplyMetaDataKey == replyMetaDataKey && postMetaData.author != replyMetaData.author) {
                changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &i64Lib::sub(&newTypeRating.acceptedReply, &oldTypeRating.acceptedReply));
                changePostAuthorRating = i64Lib::add(&changePostAuthorRating, &i64Lib::sub(&newTypeRating.acceptReply, &oldTypeRating.acceptReply));
            };

            userLib::updateRating(
                usersRatingCollection,
                replyMetaData.author,
                achievementCollection,
                changeReplyAuthorRating,
                postMetaData.communityId,
                ctx,
            );
            replyMetaDataKey = replyMetaDataKey + 1;
        };
        userLib::updateRating(
            usersRatingCollection,
            postMetaData.author,
            achievementCollection,
            changePostAuthorRating,
            postMetaData.communityId,
            ctx,
        );

        postMetaData.postType = newPostType;
    }

    /// Change `communityId` for the `post` and recalculation `rating` for all `users` who were active in the `post`
    fun changePostCommunity(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        postMetaData: &mut PostMetaData,
        community: &communityLib::Community,
        ctx: &mut TxContext,
    ) {
        let newCommunityId = object::id(community);

        communityLib::onlyNotFrozenCommunity(community);
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
            if (bestReplyMetaDataKey == replyMetaDataKey && postMetaData.author != replyMetaData.author) {
                changeReplyAuthorRating = i64Lib::add(&changeReplyAuthorRating, &typeRating.acceptedReply);
                changePostAuthorRating = i64Lib::add(&changeReplyAuthorRating, &typeRating.acceptReply);
            };

            userLib::updateRating(
                usersRatingCollection,
                replyMetaData.author,
                achievementCollection,
                i64Lib::mul(&changeReplyAuthorRating, &i64Lib::neg_from(1)),
                oldCommunityId,
                ctx,
            );
            userLib::updateRating(
                usersRatingCollection,
                replyMetaData.author,
                achievementCollection,
                changeReplyAuthorRating,
                newCommunityId,
                ctx,
            );
            replyMetaDataKey = replyMetaDataKey + 1;
        };

        userLib::updateRating(
            usersRatingCollection,
            postMetaData.author,
            achievementCollection,
            i64Lib::mul(&changePostAuthorRating, &i64Lib::neg_from(1)),
            oldCommunityId,
            ctx,
        );
        userLib::updateRating(
            usersRatingCollection,
            postMetaData.author,
            achievementCollection,
            changePostAuthorRating,
            newCommunityId,
            ctx,
        );
        postMetaData.communityId = newCommunityId;
    }

    /// Check overlap `item object id` and `itemMetaData.itemId` (for post/reply/comment)
    fun checkMatchItemId(
        itemId: ID,
        savedItemId: ID
    ) {
        assert!(
            itemId == savedItemId,
            E_ITEM_ID_NOT_MATCHING
        ); 
    }

    /// Get constants `rating` depends on `post type` (upvotedPost, downvotedPost, upvotedReply, downvotedReply, firstReply, quickReply, acceptedReply, acceptReply)
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

    /// Get count upvotes/downvotes for the `item meta data`
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

    /// Get the mutable `reply meta data`
    public fun getMutableReplyMetaData(postMetaData: &mut PostMetaData, replyMetaDataKey: u64): &mut ReplyMetaData {
        assert!(replyMetaDataKey >= 0, E_ITEM_ID_CAN_NOT_BE_0);
        assert!(table::length(&postMetaData.replies) >= replyMetaDataKey, E_REPLY_NOT_EXIST);
        let replyMetaData = table::borrow_mut<u64, ReplyMetaData>(&mut postMetaData.replies, replyMetaDataKey);
        replyMetaData
    }

    /// Get the mutable `reply meta data` + (check status deleted for `post/reply`)
    public fun getMutableReplyMetaDataSafe(postMetaData: &mut PostMetaData, replyMetaDataKey: u64): &mut ReplyMetaData {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let replyMetaData = getMutableReplyMetaData(postMetaData, replyMetaDataKey);
        assert!(!replyMetaData.isDeleted, E_REPLY_DELETED);
        replyMetaData
    }

    /// Get the `reply meta data`
    public fun getReplyMetaData(postMetaData: &PostMetaData, replyMetaDataKey: u64): &ReplyMetaData {
        assert!(replyMetaDataKey > 0, E_ITEM_ID_CAN_NOT_BE_0);
        assert!(table::length(&postMetaData.replies) >= replyMetaDataKey, E_REPLY_NOT_EXIST);
        let replyMetaData = table::borrow<u64, ReplyMetaData>(&postMetaData.replies, replyMetaDataKey);
        replyMetaData
    }

    /// Get the `reply meta data` + (check status deleted for `post/reply`)
    public fun getReplyMetaDataSafe(postMetaData: &PostMetaData, replyMetaDataKey: u64): &ReplyMetaData {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
        assert!(!replyMetaData.isDeleted, E_REPLY_DELETED);
        replyMetaData
    }

    /// Get the mutable `comment meta data`
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

    /// Get the mutable `comment meta data` + (check status deleted for `post/reply/comment`)
    public fun getMutableCommentMetaDataSafe(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): &mut CommentMetaData {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let commentMetaData = getMutableCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);
        assert!(!commentMetaData.isDeleted, E_COMMENT_DELETED);
        commentMetaData
    }

    /// Get the `comment meta data`
    public fun getCommentMetaData(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): &CommentMetaData {
        getMutableCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey)
    }

    /// Get the `comment meta data` + (check status deleted for post/reply/comment)
    public fun getCommentMetaDataSafe(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): &CommentMetaData {
        assert!(!postMetaData.isDeleted, E_POST_DELETED);
        let commentMetaData = getCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);
        assert!(!commentMetaData.isDeleted, E_COMMENT_DELETED);
        commentMetaData
    }

    /// Get active `reply` count for the `post` (created replies - deleted replies)
    fun getActiveReplyCount(
        postMetaData: &PostMetaData
    ): u64 {
        return table::length(&postMetaData.replies) - postMetaData.deletedRepliesCount
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
    const MODERATOR_DELETE_REPLY: u64 = 2;      // negative

/////////////////////////////////////////////////////////////////////////////////

    const MODERATOR_DELETE_COMMENT: u64 = 1;    // negative

    /// Get constants rating for expert post type (upvotedPost, downvotedPost, upvotedReply, downvotedReply, firstReply, quickReply, acceptedReply, acceptReply)
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

    /// Get constants rating for common post type (upvotedPost, downvotedPost, upvotedReply, downvotedReply, firstReply, quickReply, acceptedReply, acceptReply)
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

    /// Get constants rating for tutorial post type (upvotedPost, downvotedPost, upvotedReply, downvotedReply, firstReply, quickReply, acceptedReply, acceptReply)
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

    // --- Testing functions ---

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
    public fun getBestReplyMetaDataKey(postMetaData: &PostMetaData): u64 {
        postMetaData.bestReplyMetaDataKey
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
            postMetaData.deletedRepliesCount,
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
    public fun getPostRating(postMetaData: &PostMetaData): (i64Lib::I64) {
        (
            postMetaData.rating,
        )
    }

    #[test_only]
    public fun getPostAuthorMetaData(postMetaData: &PostMetaData): (vector<u8>) {
        postMetaData.authorMetaData
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
    public fun getReplyRating(postMetaData: &PostMetaData, replyMetaDataKey: u64): (i64Lib::I64) {
        let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
        (
            replyMetaData.rating,
        )
    }

    #[test_only]
    public fun getReplyAuthorMetaData(postMetaData: &PostMetaData, replyMetaDataKey: u64): (vector<u8>) {
        let replyMetaData = getReplyMetaData(postMetaData, replyMetaDataKey);
        replyMetaData.authorMetaData
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

    #[test_only]
    public fun getCommentRating(postMetaData: &mut PostMetaData, parentReplyMetaDataKey: u64, commentMetaDataKey: u64): (i64Lib::I64) {
        let commentMetaData = getCommentMetaData(postMetaData, parentReplyMetaDataKey, commentMetaDataKey);
        (
            commentMetaData.rating,
        )
    }
}
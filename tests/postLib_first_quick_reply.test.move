#[test_only]
module basics::postLib_first_quick_reply_test
{
    use basics::postLib::{Self, PostMetaData, Reply};
    use basics::postLib_changePostType_test;
    use basics::communityLib::{Community};
    use basics::userLib::{User, UsersRatingCollection, PeriodRewardContainer};
    use basics::accessControlLib::{UserRolesCollection};
    use sui::test_scenario::{Self, Scenario};
    use sui::clock::{Self};

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;

    const UPVOTE_FLAG: bool = true;
    const DOWNVOTE_FLAG: bool = false;

    const START_USER_RATING: u64 = 10;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;

    
    #[test]
    fun test_create_first_reply_to_expert_post() {     //  first reply after delete previous reply to expert post
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_changePostType_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;

            let (
                _ipfsDoc,
                _replyId,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                _language,
                isFirstReply,
                isQuickReply,
                _isDeleted,
                _historyVotes
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(isFirstReply == true, 1);
            assert!(isQuickReply == true, 2);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;

            let (
                _ipfsDoc,
                _replyId,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                _language,
                isFirstReply,
                isQuickReply,
                _isDeleted,
                _historyVotes
            ) = postLib::getReplyData(post_meta_data, reply, 2);

            assert!(isFirstReply == true, 1);
            assert!(isQuickReply == true, 2);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_reply_to_common_post() {     //  first reply after delete previous reply to commom post
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_changePostType_test::init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;

            let (
                _ipfsDoc,
                _replyId,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                _language,
                isFirstReply,
                isQuickReply,
                _isDeleted,
                _historyVotes
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(isFirstReply == true, 1);
            assert!(isQuickReply == true, 2);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;

            let (
                _ipfsDoc,
                _replyId,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                _language,
                isFirstReply,
                isQuickReply,
                _isDeleted,
                _historyVotes
            ) = postLib::getReplyData(post_meta_data, reply, 2);

            assert!(isFirstReply == true, 1);
            assert!(isQuickReply == true, 2);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

   
    // ====== Support functions ======

    #[test_only]
    fun init_all_shared(scenario: &mut Scenario): (UsersRatingCollection, UserRolesCollection, PeriodRewardContainer, User, Community) {
        let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let period_reward_container_val = test_scenario::take_shared<PeriodRewardContainer>(scenario);
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let community_val = test_scenario::take_shared<Community>(scenario);

        (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val)
    }

    #[test_only]
    fun return_all_shared(
        user_rating_collection_val: UsersRatingCollection,
        user_roles_collection_val: UserRolesCollection,
        period_reward_container_val:PeriodRewardContainer,
        user_val: User,
        community_val: Community,
        scenario: &mut Scenario
    ) {
        test_scenario::return_shared(user_rating_collection_val);
        test_scenario::return_shared(user_roles_collection_val);
        test_scenario::return_shared(period_reward_container_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(community_val);
    }
}
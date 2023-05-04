#[test_only]
module basics::postLib_first_quick_reply_rating_test
{
    use sui::object::{Self};
    use basics::postLib::{PostMetaData};
    use basics::postLib_votes_test;
    use basics::userLib_test;
    use basics::communityLib_test;
    use basics::postLib_changePostType_test;
    use basics::communityLib::{Community};
    use basics::userLib::{Self, User, UsersRatingCollection, PeriodRewardContainer};
    use basics::accessControlLib::{Self, UserRolesCollection};
    use sui::test_scenario::{Self, Scenario};
    use basics::i64Lib;
    use sui::clock::{Self};

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;

    const UPVOTE_FLAG: bool = true;
    const DOWNVOTE_FLAG: bool = false;

    const START_USER_RATING: u64 = 10;

    //expert reply
    const UPVOTED_EXPERT_REPLY: u64 = 10;
    const DOWNVOTED_EXPERT_REPLY: u64 = 2;      // negative
    const FIRST_EXPERT_REPLY: u64 = 5;
    const QUICK_EXPERT_REPLY: u64 = 5;

    //common reply
    const UPVOTED_COMMON_REPLY: u64 = 1;
    const DOWNVOTED_COMMON_REPLY: u64 = 1;      // negative
    const FIRST_COMMON_REPLY: u64 = 1;
    const QUICK_COMMON_REPLY: u64 = 1;

    const DELETE_OWN_REPLY: u64 = 1;            // negative

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    
    #[test]
    fun test_create_first_quick_reply_to_expert_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::add(
                &i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(FIRST_EXPERT_REPLY)),
                &i64Lib::from(QUICK_EXPERT_REPLY)
            );
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
            assert!(expectedVoteUserRating == voteUserRating, 0);

            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_quick_reply_to_common_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::add(
                &i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(FIRST_COMMON_REPLY)),
                &i64Lib::from(QUICK_COMMON_REPLY)
            );
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
            assert!(expectedVoteUserRating == voteUserRating, 0);

            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_reply_after_delete_previos_reply_to_expert_post_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating =  i64Lib::sub(
                &i64Lib::add(
                    &i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(FIRST_EXPERT_REPLY)),
                    &i64Lib::from(QUICK_EXPERT_REPLY)
                ),
                &i64Lib::from(DELETE_OWN_REPLY)
            );
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
            assert!(expectedVoteUserRating == voteUserRating, 0);

            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_reply_after_delete_previos_reply_to_common_post_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating =  i64Lib::sub(
                &i64Lib::add(
                    &i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(FIRST_COMMON_REPLY)),
                    &i64Lib::from(QUICK_COMMON_REPLY)
                ),
                &i64Lib::from(DELETE_OWN_REPLY)
            );
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
            assert!(expectedVoteUserRating == voteUserRating, 0);

            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_downvote_first_quick_reply_to_expert_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
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
            postLib_votes_test::vote_reply(post_meta_data, 1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_EXPERT_REPLY));
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
            assert!(expectedVoteUserRating == voteUserRating, 0);

            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_downvote_first_quick_reply_to_common_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
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
            postLib_votes_test::vote_reply(post_meta_data, 1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_COMMON_REPLY));
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
            assert!(expectedVoteUserRating == voteUserRating, 0);

            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

   
    // ====== Support functions ======

    #[test_only]
    public fun init_postLib_test(postType: u8, scenario: &mut Scenario): clock::Clock {
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControlLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_changePostType_test::create_post(&time, postType, scenario);
        };

        time
    }

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

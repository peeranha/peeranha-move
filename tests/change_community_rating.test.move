#[test_only]
module peeranha::postLib_change_community_rating_test
{
    use peeranha::postLib::{Self, PostMetaData};
    use peeranha::nftLib::{AchievementCollection};
    use peeranha::postLib_votes_test;
    use peeranha::postLib_votes_rating_test;
    use peeranha::postLib_change_community_test;
    use peeranha::postLib_change_post_type_test;
    use sui::test_scenario::{Self};
    use peeranha::i64Lib;
    use sui::clock;

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;

    const UPVOTE_FLAG: bool = true;
    const DOWNVOTE_FLAG: bool = false;

    const START_USER_RATING: u64 = 10;

    //expert reply
    const UPVOTED_EXPERT_REPLY: u64 = 10;
    const DOWNVOTED_EXPERT_REPLY: u64 = 2;      // negative
    const ACCEPTED_EXPERT_REPLY: u64 = 15;
    const FIRST_EXPERT_REPLY: u64 = 5;
    const QUICK_EXPERT_REPLY: u64 = 5;

    //common reply
    const UPVOTED_COMMON_REPLY: u64 = 1;
    const DOWNVOTED_COMMON_REPLY: u64 = 1;      // negative
    const ACCEPTED_COMMON_REPLY: u64 = 3;
    const FIRST_COMMON_REPLY: u64 = 1;
    const QUICK_COMMON_REPLY: u64 = 1;

    //expert post
    const DOWNVOTE_EXPERT_POST: u64 = 1;        // negative
    const UPVOTED_EXPERT_POST: u64 = 5;
    const DOWNVOTED_EXPERT_POST: u64 = 2;       // negative

    //common post 
    const DOWNVOTE_COMMON_POST: u64 = 1;        // negative
    const UPVOTED_COMMON_POST: u64 = 1;
    const DOWNVOTED_COMMON_POST: u64 = 1;       // negative

    //tutorial 
    // const DOWNVOTE_TUTORIAL: u64 = 1;           // negative
    const UPVOTED_TUTORIAL: u64 = 5;
    const DOWNVOTED_TUTORIAL: u64 = 2;

    const DELETE_OWN_REPLY: u64 = 1;            // negative
    const MODERATOR_DELETE_REPLY: u64 = 2;      // negative

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const USER3: address = @0xA3;
    const USER4: address = @0xA4;
    const USER5: address = @0xA5;

    #[test]
    fun test_create_quick_reply_to_expert_post_with_changed_community() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + QUICK_EXPERT_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_quick_reply_to_expert_post_with_changed_community() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_quick_reply_to_common_post_with_changed_community() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + QUICK_COMMON_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_quick_reply_to_common_post_with_changed_community() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_reply_after_delete_previos_reply_to_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_reply_after_delete_previos_reply_to_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_community_test::change_post_community(post_meta_data1, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + UPVOTED_EXPERT_POST);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_community_test::change_post_community(post_meta_data1, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + UPVOTED_COMMON_POST);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_tutorial_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_community_test::change_post_community(post_meta_data1, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + UPVOTED_TUTORIAL);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_downvote_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_community_test::change_post_community(post_meta_data1, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING - DOWNVOTED_EXPERT_POST);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_downvote_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_community_test::change_post_community(post_meta_data1, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING - DOWNVOTED_COMMON_POST);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_downvote_tutorial_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_community_test::change_post_community(post_meta_data1, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING - DOWNVOTED_TUTORIAL);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_two_downvote_and_one_upvote_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER4);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER5);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_community_test::change_post_community(post_meta_data1, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DOWNVOTE_EXPERT_POST);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER5);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::zero();
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };


        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_first_quick_reply_to_downvoted_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_post_type_test::create_reply(post_meta_data1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_community_test::change_post_community(post_meta_data1, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DOWNVOTE_EXPERT_POST);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_first_quick_reply_to_downvoted_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_post_type_test::create_reply(post_meta_data1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_votes_test::vote_post(post_meta_data1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val2 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data_val1 = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data1 = &mut post_meta_data_val1;
            postLib_change_community_test::change_post_community(post_meta_data1, scenario);
            test_scenario::return_shared(post_meta_data_val1);
            test_scenario::return_shared(post_meta_data_val2);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DOWNVOTE_COMMON_POST);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_quick_reply_to_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 2, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + QUICK_EXPERT_REPLY + UPVOTED_EXPERT_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_quick_reply_to_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 2, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + QUICK_COMMON_REPLY + UPVOTED_COMMON_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_first_quick_reply_to_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY + UPVOTED_EXPERT_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_first_quick_reply_to_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY + UPVOTED_COMMON_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_downvote_first_quick_reply_to_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING - DOWNVOTED_EXPERT_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_downvote_first_quick_reply_to_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING - DOWNVOTED_COMMON_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_downvoted_first_quick_reply_to_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY + UPVOTED_EXPERT_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_downvoted_first_quick_reply_to_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY + UPVOTED_COMMON_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_first_quick_reply_to_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_first_quick_reply_to_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_first_quick_reply_by_moderator_to_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - MODERATOR_DELETE_REPLY);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_first_quick_reply_by_moderator_to_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - MODERATOR_DELETE_REPLY);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_reply_with_upvoted_first_quick_reply_to_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_reply_with_upvoted_first_quick_reply_to_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }
    
    #[test]
    fun test_delete_reply_with_downvoted_first_quick_reply_to_expert_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
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
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY - DOWNVOTED_EXPERT_REPLY);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_reply_with_downvoted_first_quick_reply_to_common_post_with_changed_community_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
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
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::zero();
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY - DOWNVOTED_COMMON_REPLY);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_quick_best_reply_to_common_post_with_changed_community() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let achievement_collection_val = test_scenario::take_shared<AchievementCollection>(scenario);
            let achievement_collection = &mut achievement_collection_val;let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario),
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_shared(achievement_collection_val);
            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY + ACCEPTED_COMMON_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_quick_best_reply_to_expert_post_with_changed_community() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let achievement_collection_val = test_scenario::take_shared<AchievementCollection>(scenario);
            let achievement_collection = &mut achievement_collection_val;let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario),
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_shared(achievement_collection_val);
            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY + ACCEPTED_EXPERT_REPLY);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_own_reply_with_changed_community() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_community_test::init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_community_test::change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = postLib_change_community_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let community2 = &mut community2_val;
            let user = &mut user_val;

            let expectedVotedUserNewCommunityRating = &i64Lib::from(0);
            let votedUserNewCommunityRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community2);
            let expectedVotedUserOldCommunityRating = &i64Lib::from(START_USER_RATING);
            let votedUseOldCommunityrRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedVotedUserOldCommunityRating == &votedUseOldCommunityrRating, 0);
            assert!(expectedVotedUserNewCommunityRating == &votedUserNewCommunityRating, 1);

            postLib_change_community_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val,  community_val, community2_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }
}

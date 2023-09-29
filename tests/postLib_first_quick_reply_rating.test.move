#[test_only]
module peeranha::postLib_first_quick_reply_rating_test
{
    use peeranha::postLib::{PostMetaData};
    use peeranha::nftLib;
    use peeranha::postLib_test;
    use peeranha::postLib_votes_test;
    use peeranha::postLib_votes_rating_test;
    use peeranha::userLib_test;
    use peeranha::communityLib_test;
    use peeranha::postLib_change_post_type_test;
    use peeranha::userLib::{Self};
    use peeranha::accessControlLib;
    use sui::test_scenario::{Self, Scenario};
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
    const FIRST_EXPERT_REPLY: u64 = 5;
    const QUICK_EXPERT_REPLY: u64 = 5;

    //common reply
    const UPVOTED_COMMON_REPLY: u64 = 1;
    const DOWNVOTED_COMMON_REPLY: u64 = 1;      // negative
    const FIRST_COMMON_REPLY: u64 = 1;
    const QUICK_COMMON_REPLY: u64 = 1;

    const DELETE_OWN_REPLY: u64 = 1;            // negative
    const DELETE_OWN_POST: u64 = 1;             // negative

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const USER3: address = @0xA3;

    #[test]
    fun test_create_quick_reply_to_expert_post() {
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

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + QUICK_EXPERT_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }
    
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
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_quick_reply_to_common_post() {
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

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + QUICK_COMMON_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
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
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY - DELETE_OWN_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY - DELETE_OWN_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_quick_reply_to_expert_post_rating() {
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

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + QUICK_EXPERT_REPLY + UPVOTED_EXPERT_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_quick_reply_to_common_post_rating() {
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

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + QUICK_COMMON_REPLY + UPVOTED_COMMON_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_first_quick_reply_to_expert_post_rating() {
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY + UPVOTED_EXPERT_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_first_quick_reply_to_common_post_rating() {
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY + UPVOTED_COMMON_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_downvote_first_quick_reply_to_expert_post_rating() {
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DOWNVOTED_EXPERT_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_downvote_first_quick_reply_to_common_post_rating() {
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DOWNVOTED_COMMON_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_downvoted_first_quick_reply_to_expert_post_rating() {
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY + UPVOTED_EXPERT_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_upvote_downvoted_first_quick_reply_to_common_post_rating() {
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY + UPVOTED_COMMON_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_post_with_first_quick_reply_to_expert_post_rating() {
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
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_rating_test::delete_post(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_post_with_first_quick_reply_to_common_post_rating() {
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
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_rating_test::delete_post(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_first_quick_reply_to_expert_post_rating() {
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_first_quick_reply_to_common_post_rating() {
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating =  i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_post_with_downvoted_first_quick_reply_to_expert_post_rating() {
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
            postLib_votes_rating_test::delete_post(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DOWNVOTED_EXPERT_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_post_with_downvoted_first_quick_reply_to_common_post_rating() {
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
            postLib_votes_rating_test::delete_post(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating =i64Lib::from(START_USER_RATING - DOWNVOTED_COMMON_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_reply_with_downvoted_first_quick_reply_to_expert_post_rating() {
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY - DOWNVOTED_EXPERT_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_reply_with_downvoted_first_quick_reply_to_common_post_rating() {
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY - DOWNVOTED_COMMON_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_reply_to_own_post_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(COMMON_POST, scenario);
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(0);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

   
    // ====== Support functions ======

    #[test_only]
    public fun init_postLib_test(postType: u8, scenario: &mut Scenario): clock::Clock {
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::test_init(test_scenario::ctx(scenario));
            nftLib::test_init(test_scenario::ctx(scenario));
            accessControlLib::test_init(test_scenario::ctx(scenario));
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

        test_scenario::next_tx(scenario, USER3);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_change_post_type_test::create_post(&time, postType, scenario);
        };

        time
    }
}

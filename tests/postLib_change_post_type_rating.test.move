#[test_only]
module basics::postLib_changePostType_rating_test
{
    use basics::postLib::{Self, PostMetaData};
    use basics::userLib::{User};
    use basics::postLib_test;
    use basics::postLib_votes_test;
    use basics::postLib_votes_rating_test;
    use basics::i64Lib;
    use basics::postLib_change_post_type_test;
    use sui::test_scenario::{Self};
    use sui::clock::{Self};
    // use std::debug;
    // debug::print(community);

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;

    const UPVOTE_FLAG: bool = true;
    const DOWNVOTE_FLAG: bool = false;

    const ENGLISH_LANGUAGE: u8 = 0;

    const START_USER_RATING: u64 = 10;

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

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;

    #[test]
    fun test_change_upvoted_expert_post_to_common_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + UPVOTED_COMMON_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_upvoted_expert_post_to_tutorial_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, TUTORIAL, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + UPVOTED_TUTORIAL);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_upvoted_common_post_to_expert_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + UPVOTED_EXPERT_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_upvoted_common_post_to_tutorial_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, TUTORIAL, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + UPVOTED_TUTORIAL);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_upvoted_tutorial_to_expert_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + UPVOTED_EXPERT_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_upvoted_tutorial_to_common_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + UPVOTED_COMMON_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_downvoted_expert_post_to_common_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DOWNVOTED_COMMON_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            
            let expectedVoteUserRating = i64Lib::from(START_USER_RATING - DOWNVOTE_COMMON_POST);
            let voteUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVoteUserRating == voteUserRating, 1);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_downvoted_expert_post_to_tutorial_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, TUTORIAL, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DOWNVOTED_TUTORIAL);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            
            let expectedVoteUserRating = i64Lib::from(START_USER_RATING - DOWNVOTE_TUTORIAL);
            let voteUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVoteUserRating == voteUserRating, 1);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_downvoted_common_post_to_expert_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_EXPERT_POST));
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTE_EXPERT_POST));
            let voteUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVoteUserRating == voteUserRating, 1);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_downvoted_common_post_to_tutorial_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, TUTORIAL, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_TUTORIAL));
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTE_TUTORIAL));
            let voteUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVoteUserRating == voteUserRating, 1);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_downvoted_tutorial_to_expert_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DOWNVOTED_EXPERT_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            
            let expectedVoteUserRating = i64Lib::from(START_USER_RATING - DOWNVOTE_EXPERT_POST);
            let voteUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVoteUserRating == voteUserRating, 1);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_downvoted_tutorial_to_common_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_change_post_type_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DOWNVOTED_COMMON_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            
            let expectedVoteUserRating = i64Lib::from(START_USER_RATING - DOWNVOTE_COMMON_POST);
            let voteUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVoteUserRating == voteUserRating, 1);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_expert_post_to_common_with_upvoted_reply_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
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
            postLib_change_post_type_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + UPVOTED_COMMON_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_common_post_to_expert_with_upvoted_reply_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
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
            postLib_change_post_type_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING + UPVOTED_EXPERT_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_expert_post_to_common_with_downvoted_reply_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
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
            postLib_change_post_type_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DOWNVOTED_COMMON_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            
            let expectedVoteUserRating = i64Lib::from(START_USER_RATING - DOWNVOTE_COMMON_REPLY);
            let voteUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVoteUserRating == voteUserRating, 1);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_common_post_to_expert_with_downvoted_reply_rating() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
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
            postLib_change_post_type_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DOWNVOTED_EXPERT_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            
            let expectedVoteUserRating = i64Lib::from(START_USER_RATING - DOWNVOTE_EXPERT_REPLY);
            let voteUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVoteUserRating == voteUserRating, 1);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    // ====== Best Reply ======

    #[test]
    fun test_mark_best_reply_expert_to_common() {
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
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user1_val;
        test_scenario::next_tx(scenario, USER1);
        {
            user1_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING + ACCEPT_EXPERT_REPLY);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY + ACCEPTED_EXPERT_REPLY);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user1_val, community);            
            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);

            postLib_changePostType_test::change_post_type_all_params(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                community,
                COMMON_POST,
                scenario
            );

            let newExpectedPostAuthorIdRating = i64Lib::from(START_USER_RATING + ACCEPT_COMMON_REPLY);
            let newPostAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let newExpectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY + ACCEPTED_COMMON_REPLY);
            let newReplyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user1_val, community);            
            assert!(newExpectedPostAuthorIdRating == newPostAuthorRating, 0);
            assert!(newExpectedReplyAuthorIdRating == newReplyAuthorRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            test_scenario::return_to_sender(scenario, user1_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_mark_best_reply_common_to_expert() {
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
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user1_val;
        test_scenario::next_tx(scenario, USER1);
        {
            user1_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING + ACCEPT_COMMON_REPLY);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY + ACCEPTED_COMMON_REPLY);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user1_val, community);            
            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);

            postLib_changePostType_test::change_post_type_all_params(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                community,
                EXPERT_POST,
                scenario
            );

            let newExpectedPostAuthorIdRating = i64Lib::from(START_USER_RATING + ACCEPT_EXPERT_REPLY);
            let newPostAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let newExpectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY + ACCEPTED_EXPERT_REPLY);
            let newReplyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user1_val, community);            
            assert!(newExpectedPostAuthorIdRating == newPostAuthorRating, 0);
            assert!(newExpectedReplyAuthorIdRating == newReplyAuthorRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            test_scenario::return_to_sender(scenario, user1_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }
}

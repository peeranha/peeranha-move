#[test_only]
module basics::postLib_changePostType_rating_test
{
    use sui::object::{Self};
    use basics::postLib::{PostMetaData};
    use basics::postLib_test;
    use basics::postLib_votes_test;
    use basics::userLib::{Self};
    use basics::i64Lib;
    use basics::postLib_changePostType_test;
    use sui::test_scenario::{Self};
    use sui::clock::{Self};

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

    //common reply
    const DOWNVOTE_COMMON_REPLY: u64 = 1;       // negative
    const UPVOTED_COMMON_REPLY: u64 = 1;
    const DOWNVOTED_COMMON_REPLY: u64 = 1;      // negative

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;

    #[test]
    fun test_change_upvoted_expert_post_to_common_rating() {
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
            postLib_votes_test::vote_post(post_meta_data, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(UPVOTED_COMMON_POST));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(EXPERT_POST, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, TUTORIAL, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(UPVOTED_TUTORIAL));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(COMMON_POST, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(UPVOTED_EXPERT_POST));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(COMMON_POST, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, TUTORIAL, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(UPVOTED_TUTORIAL));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(TUTORIAL, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(UPVOTED_EXPERT_POST));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(TUTORIAL, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(UPVOTED_COMMON_POST));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(EXPERT_POST, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_COMMON_POST));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTE_COMMON_POST));
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(EXPERT_POST, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, TUTORIAL, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_TUTORIAL));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTE_TUTORIAL));
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(COMMON_POST, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_EXPERT_POST));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTE_EXPERT_POST));
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(COMMON_POST, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, TUTORIAL, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_TUTORIAL));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTE_TUTORIAL));
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(TUTORIAL, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_EXPERT_POST));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTE_EXPERT_POST));
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(TUTORIAL, scenario);
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
            postLib_changePostType_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_COMMON_POST));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTE_COMMON_POST));
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(EXPERT_POST, scenario);
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
            postLib_votes_test::vote_reply(post_meta_data, 1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(UPVOTED_COMMON_REPLY));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(COMMON_POST, scenario);
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
            postLib_votes_test::vote_reply(post_meta_data, 1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(UPVOTED_EXPERT_REPLY));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(EXPERT_POST, scenario);
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
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::change_post_type(post_meta_data, COMMON_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_COMMON_REPLY));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTE_COMMON_REPLY));
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
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
            time = postLib_changePostType_test::init_postLib_test(COMMON_POST, scenario);
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
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_changePostType_test::change_post_type(post_meta_data, EXPERT_POST, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let votedUserId = object::id(user);

            let votedUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, votedUserId);
            let expectedVotedUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTED_EXPERT_REPLY));
            let votedUserRating = userLib::getUserRating(votedUserCommunityRating, communityId);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let communityId = object::id(community);
            let voteUserId = object::id(user);

            let voteUserCommunityRating = userLib::getUserCommunityRating(user_rating_collection, voteUserId);
            let expectedVoteUserRating = i64Lib::sub(&i64Lib::from(START_USER_RATING), &i64Lib::from(DOWNVOTE_EXPERT_REPLY));
            let voteUserRating = userLib::getUserRating(voteUserCommunityRating, communityId);
            
            assert!(expectedVoteUserRating == voteUserRating, 1);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }
}

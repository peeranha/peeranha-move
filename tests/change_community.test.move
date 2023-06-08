#[test_only]
module basics::postLib_change_community_test
{
    use basics::userLib::{Self, User, UsersRatingCollection};
    use basics::accessControlLib::{Self, UserRolesCollection, DefaultAdminCap};
    use basics::communityLib::{Community};
    use basics::postLib::{Self, Post, PostMetaData};
    use basics::postLib_change_post_type_test;
    use basics::userLib_test;
    use basics::communityLib_test;
    use sui::test_scenario::{Self, Scenario};
    use sui::clock::{Self};
    use sui::object::{Self};

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;

    const UPVOTE_FLAG: bool = true;
    const DOWNVOTE_FLAG: bool = false;

    const START_USER_RATING: u64 = 10;

    const ENGLISH_LANGUAGE: u8 = 0;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const USER3: address = @0xA3;
    const USER4: address = @0xA4;
    const USER5: address = @0xA5;

    const COMMUNITY_ADMIN_ROLE: vector<u8> = vector<u8>[3];

    
    #[test]
    fun test_change_post_community_for_expert_post() {     //  change community for expert post
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_community_change_type_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let community2_val = test_scenario::take_shared<Community>(scenario);
            let community2 = &mut community2_val;
            let communityId2 = object::id(community2);
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;

            let (
                _ipfsDoc,
                _postId,
                _postType,
                _author,
                _rating,
                communityId,
                _language,
                _officialReplyMetaDataKey,
                _bestReplyMetaDataKey,
                _deletedRepliesCount,
                _isDeleted,
                _tags,
                _historyVotes
            ) = postLib::getPostData(post_meta_data, post);

            assert!(communityId == communityId2, 1);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_shared(community2_val);
            test_scenario::return_to_sender(scenario, post_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_post_community_for_common_post() {     //  change community for common post
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_community_change_type_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let community2_val = test_scenario::take_shared<Community>(scenario);
            let community2 = &mut community2_val;
            let communityId2 = object::id(community2);
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;

            let (
                _ipfsDoc,
                _postId,
                _postType,
                _author,
                _rating,
                communityId,
                _language,
                _officialReplyMetaDataKey,
                _bestReplyMetaDataKey,
                _deletedRepliesCount,
                _isDeleted,
                _tags,
                _historyVotes
            ) = postLib::getPostData(post_meta_data, post);

            assert!(communityId == communityId2, 1);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_shared(community2_val);
            test_scenario::return_to_sender(scenario, post_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_post_community_for_tutorial_post() {     //  change community for tutorial post
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_community_change_type_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            change_post_community(post_meta_data, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let community2_val = test_scenario::take_shared<Community>(scenario);
            let community2 = &mut community2_val;
            let communityId2 = object::id(community2);
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;

            let (
                _ipfsDoc,
                _postId,
                _postType,
                _author,
                _rating,
                communityId,
                _language,
                _officialReplyMetaDataKey,
                _bestReplyMetaDataKey,
                _deletedRepliesCount,
                _isDeleted,
                _tags,
                _historyVotes
            ) = postLib::getPostData(post_meta_data, post);

            assert!(communityId == communityId2, 1);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_shared(community2_val);
            test_scenario::return_to_sender(scenario, post_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

// ====== Support functions ======

    #[test_only]
    public fun init_community_change_type_test(postType: u8, scenario: &mut Scenario): clock::Clock {
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

        test_scenario::next_tx(scenario, USER3);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_change_post_type_test::create_post(&time, postType, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_change_post_type_test::create_post(&time, postType, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER4);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER5);
        {
            userLib_test::create_user(scenario);
        };

        let user5_val;
        test_scenario::next_tx(scenario, USER5);
        {
            user5_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val,user_roles_collection_val, user_val, community_val, community2_val) = init_all_shared(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user5 = &mut user5_val;

            let default_admin_cap_val = test_scenario::take_from_sender<DefaultAdminCap>(scenario);
            let default_admin_cap = &mut default_admin_cap_val;

            accessControlLib::grantProtocolAdminRole(default_admin_cap, user_roles_collection, object::id(user5));
            
            test_scenario::return_to_sender(scenario, default_admin_cap_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER5);
        {
            test_scenario::return_to_sender(scenario, user5_val);
        };

        let user4_val;
        test_scenario::next_tx(scenario, USER4);
        {
            user4_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = init_all_shared(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user4 = &mut user4_val;

            let default_admin_cap_val = test_scenario::take_from_sender<DefaultAdminCap>(scenario);
            let default_admin_cap = &mut default_admin_cap_val;

            accessControlLib::grantProtocolAdminRole(default_admin_cap, user_roles_collection, object::id(user4));
            
            test_scenario::return_to_sender(scenario, default_admin_cap_val);

            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER4);
        {
            test_scenario::return_to_sender(scenario, user4_val);
        };
        

        time
    }

    #[test_only]
    public fun init_all_shared(scenario: &mut Scenario): (UsersRatingCollection, UserRolesCollection, User, Community, Community) {
        let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let community2_val = test_scenario::take_shared<Community>(scenario);
        let community_val = test_scenario::take_shared<Community>(scenario);

        (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val)
    }

    #[test_only]
    public fun return_all_shared(
        user_rating_collection_val: UsersRatingCollection,
        user_roles_collection_val: UserRolesCollection,
        user_val: User,
        community_val: Community,
        community_val2: Community,
        scenario: &mut Scenario
    ) {
        test_scenario::return_shared(user_rating_collection_val);
        test_scenario::return_shared(user_roles_collection_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(community_val);
        test_scenario::return_shared(community_val2);
    }
    
    #[test_only]
    public fun change_post_community(post_meta_data: &mut PostMetaData, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val) = init_all_shared(scenario);
        let post_val = test_scenario::take_from_sender<Post>(scenario);
        let post = &mut post_val;
        let postType = postLib::getPostType(post_meta_data);
        let user_rating_collection = &mut user_rating_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;
        let community2 = &mut community2_val;

        postLib::authorEditPost(
            user_rating_collection,
            user_roles_collection,
            user,
            post,
            post_meta_data,
            community2,
            x"0000000000000000000000000000000000000000000000000000000000000005",
            postType,
            vector<u64>[2, 3],
            ENGLISH_LANGUAGE,
        );

        test_scenario::return_to_sender(scenario, post_val);
        return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, community2_val, scenario);
    }
}
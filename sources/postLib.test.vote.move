#[test_only]
module basics::postLib_test_vote
{
    use basics::communityLib;
    use basics::postLib;
    use basics::userLib;
    use basics::i64Lib;
    use sui::test_scenario;

    // TODO: add enum PostType      //export
    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TYTORIAL: u8 = 2;
    const DOCUMENTATION: u8 = 3;
    const USER: address = @0xA1;
    const USER1: address = @0xA2;

    #[test]
    fun test_upvote_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post_with_type(postCollection, communityCollection, userCollection, EXPERT_POST, test_scenario::ctx(scenario));

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                true,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                ipfsDoc,
                postTime,
                author,
                rating,
                communityId,
                officialReply,
                bestReply,
                deletedReplyCount,
                isDeleted,
                tags,
                properties,
                historyVotes,
                votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
            assert!(postTime == 0, 3);
            assert!(author == USER, 4);
            assert!(rating == i64Lib::zero(), 5);
            assert!(communityId == 1, 6);
            assert!(officialReply == 0, 7);
            assert!(bestReply == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[1, 2], 11);
            assert!(properties == vector<u8>[], 12);
            assert!(historyVotes == vector<u8>[], 13);
            assert!(votedUsers == vector<address>[], 14);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);        
    }
}


    //     // upvote Post
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
    //         let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             true
    //         );

    //         let (
    //             postType,
    //             ipfsDoc,
    //             postTime,
    //             author,
    //             rating,
    //             communityId,
    //             officialReply,
    //             bestReply,
    //             deletedReplyCount,
    //             isDeleted,
    //             tags,
    //             properties,
    //             historyVotes,
    //             votedUsers
    //         ) = getPostData(postCollection, 1);

    //         assert!(postType == EXPERT_POST, 1);
    //         assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
    //         assert!(postTime == 0, 3);
    //         assert!(author == user1, 4);
    //         assert!(rating == i64Lib::from(1), 5);
    //         assert!(communityId == 1, 6);
    //         assert!(officialReply == 0, 7);
    //         assert!(bestReply == 0, 8);
    //         assert!(deletedReplyCount == 0, 9);
    //         assert!(isDeleted == false, 10);
    //         assert!(tags == vector<u64>[1, 2], 11);
    //         assert!(properties == vector<u8>[], 12);
    //         assert!(historyVotes == vector<u8>[3], 13);
    //         assert!(votedUsers == vector<address>[user2], 14);

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    //     // cancel upvote Post
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
    //         let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             true
    //         );

    //         let (
    //             postType,
    //             ipfsDoc,
    //             postTime,
    //             author,
    //             rating,
    //             communityId,
    //             officialReply,
    //             bestReply,
    //             deletedReplyCount,
    //             isDeleted,
    //             tags,
    //             properties,
    //             historyVotes,
    //             votedUsers
    //         ) = getPostData(postCollection, 1);

    //         assert!(postType == EXPERT_POST, 1);
    //         assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
    //         assert!(postTime == 0, 3);
    //         assert!(author == user1, 4);
    //         assert!(rating == i64Lib::from(0), 5);
    //         assert!(communityId == 1, 6);
    //         assert!(officialReply == 0, 7);
    //         assert!(bestReply == 0, 8);
    //         assert!(deletedReplyCount == 0, 9);
    //         assert!(isDeleted == false, 10);
    //         assert!(tags == vector<u64>[1, 2], 11);
    //         assert!(properties == vector<u8>[], 12);
    //         assert!(historyVotes == vector<u8>[2], 13);
    //         assert!(votedUsers == vector<address>[user2], 14);

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    //     // upvote after cancel upvote Post
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
    //         let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             true
    //         );

    //         let (
    //             postType,
    //             ipfsDoc,
    //             postTime,
    //             author,
    //             rating,
    //             communityId,
    //             officialReply,
    //             bestReply,
    //             deletedReplyCount,
    //             isDeleted,
    //             tags,
    //             properties,
    //             historyVotes,
    //             votedUsers
    //         ) = getPostData(postCollection, 1);

    //         assert!(postType == EXPERT_POST, 1);
    //         assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
    //         assert!(postTime == 0, 3);
    //         assert!(author == user1, 4);
    //         assert!(rating == i64Lib::from(1), 5);
    //         assert!(communityId == 1, 6);
    //         assert!(officialReply == 0, 7);
    //         assert!(bestReply == 0, 8);
    //         assert!(deletedReplyCount == 0, 9);
    //         assert!(isDeleted == false, 10);
    //         assert!(tags == vector<u64>[1, 2], 11);
    //         assert!(properties == vector<u8>[], 12);
    //         assert!(historyVotes == vector<u8>[3], 13);
    //         assert!(votedUsers == vector<address>[user2], 14);

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    //     // upvote -> downVote
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
    //         let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             false
    //         );

    //         let (
    //             postType,
    //             ipfsDoc,
    //             postTime,
    //             author,
    //             rating,
    //             communityId,
    //             officialReply,
    //             bestReply,
    //             deletedReplyCount,
    //             isDeleted,
    //             tags,
    //             properties,
    //             historyVotes,
    //             votedUsers
    //         ) = getPostData(postCollection, 1);

    //         assert!(postType == EXPERT_POST, 1);
    //         assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
    //         assert!(postTime == 0, 3);
    //         assert!(author == user1, 4);
    //         assert!(rating == i64Lib::neg_from(1), 5);
    //         assert!(communityId == 1, 6);
    //         assert!(officialReply == 0, 7);
    //         assert!(bestReply == 0, 8);
    //         assert!(deletedReplyCount == 0, 9);
    //         assert!(isDeleted == false, 10);
    //         assert!(tags == vector<u64>[1, 2], 11);
    //         assert!(properties == vector<u8>[], 12);
    //         assert!(historyVotes == vector<u8>[1], 13);
    //         assert!(votedUsers == vector<address>[user2], 14);

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    //      // upvote after cancel downVote
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
    //         let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             false
    //         );
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             true
    //         );

    //         let (
    //             postType,
    //             ipfsDoc,
    //             postTime,
    //             author,
    //             rating,
    //             communityId,
    //             officialReply,
    //             bestReply,
    //             deletedReplyCount,
    //             isDeleted,
    //             tags,
    //             properties,
    //             historyVotes,
    //             votedUsers
    //         ) = getPostData(postCollection, 1);

    //         assert!(postType == EXPERT_POST, 1);
    //         assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
    //         assert!(postTime == 0, 3);
    //         assert!(author == user1, 4);
    //         assert!(rating == i64Lib::from(1), 5);
    //         assert!(communityId == 1, 6);
    //         assert!(officialReply == 0, 7);
    //         assert!(bestReply == 0, 8);
    //         assert!(deletedReplyCount == 0, 9);
    //         assert!(isDeleted == false, 10);
    //         assert!(tags == vector<u64>[1, 2], 11);
    //         assert!(properties == vector<u8>[], 12);
    //         assert!(historyVotes == vector<u8>[3], 13);
    //         assert!(votedUsers == vector<address>[user2], 14);

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };
    // }

    // #[test]
    // fun test_downVote_post() {
    //     use sui::test_scenario;

    //     // let owner = @0xC0FFEE;
    //     let user1 = @0xA1;
    //     let user2 = @0xA2;

    //     let scenario = &mut test_scenario::begin(&user1);
    //     {
    //         // userLib::initUserCollection(test_scenario::ctx(scenario));
    //         communityLib::initCommunity(test_scenario::ctx(scenario));
    //         userLib::initUser(test_scenario::ctx(scenario));
    //         init(test_scenario::ctx(scenario));
    //     };

        
    //     // create expert post
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
    //         let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);

    //         communityLib::createCommunity(
    //             communityCollection,
    //             user1,
    //             x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
    //             vector<vector<u8>>[
    //                 x"0000000000000000000000000000000000000000000000000000000000000001",
    //                 x"0000000000000000000000000000000000000000000000000000000000000002",
    //                 x"0000000000000000000000000000000000000000000000000000000000000003",
    //                 x"0000000000000000000000000000000000000000000000000000000000000004",
    //                 x"0000000000000000000000000000000000000000000000000000000000000005"
    //             ]
    //         );

    //         createPost(
    //             postCollection,
    //             communityCollection,
    //             user1,
    //             1,
    //             x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
    //             EXPERT_POST,
    //             vector<u64>[1, 2]
    //         );

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, community_wrapper);
    //     };
        
    //     // downVote Post
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
    //         let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             false
    //         );

    //         let (
    //             _postType,
    //             _ipfsDoc,
    //             _postTime,
    //             _author,
    //             rating,
    //             _communityId,
    //             _officialReply,
    //             _bestReply,
    //             _deletedReplyCount,
    //             _isDeleted,
    //             _tags,
    //             _properties,
    //             historyVotes,
    //             votedUsers
    //         ) = getPostData(postCollection, 1);

    //         assert!(rating == i64Lib::neg_from(1), 5);
    //         assert!(historyVotes == vector<u8>[1], 13);
    //         assert!(votedUsers == vector<address>[user2], 14);

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    //     // cancel downVote Post
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
    //         let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             false
    //         );

    //         let (
    //             _postType,
    //             _ipfsDoc,
    //             _postTime,
    //             _author,
    //             rating,
    //             _communityId,
    //             _officialReply,
    //             _bestReply,
    //             _deletedReplyCount,
    //             _isDeleted,
    //             _tags,
    //             _properties,
    //             historyVotes,
    //             votedUsers
    //         ) = getPostData(postCollection, 1);

    //         assert!(rating == i64Lib::from(0), 5);
    //         assert!(historyVotes == vector<u8>[2], 13);
    //         assert!(votedUsers == vector<address>[user2], 14);

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    //     // downVote after cancel downVote Post
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
    //         let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             false
    //         );

    //         let (
    //             _postType,
    //             _ipfsDoc,
    //             _postTime,
    //             _author,
    //             rating,
    //             _communityId,
    //             _officialReply,
    //             _bestReply,
    //             _deletedReplyCount,
    //             _isDeleted,
    //             _tags,
    //             _properties,
    //             historyVotes,
    //             votedUsers
    //         ) = getPostData(postCollection, 1);

    //         assert!(rating == i64Lib::neg_from(1), 5);
    //         assert!(historyVotes == vector<u8>[1], 13);
    //         assert!(votedUsers == vector<address>[user2], 14);

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    //     // downVote -> upvote
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
    //         let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             true
    //         );

    //         let (
    //             _postType,
    //             _ipfsDoc,
    //             _postTime,
    //             _author,
    //             rating,
    //             _communityId,
    //             _officialReply,
    //             _bestReply,
    //             _deletedReplyCount,
    //             _isDeleted,
    //             _tags,
    //             _properties,
    //             historyVotes,
    //             votedUsers
    //         ) = getPostData(postCollection, 1);

    //         assert!(rating == i64Lib::from(1), 5);
    //         assert!(historyVotes == vector<u8>[3], 13);
    //         assert!(votedUsers == vector<address>[user2], 14);

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    //     // downVote after cancel upvote
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let post_wrapper = test_scenario::take_shared<PostCollection>(scenario);
    //         let postCollection = test_scenario::borrow_mut(&mut post_wrapper);
    //         let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             true
    //         );
    //         voteForumItem(
    //             postCollection,
    //             userCollection,
    //             user2,
    //             1,
    //             0,
    //             0,
    //             false
    //         );

    //         let (
    //             _postType,
    //             _ipfsDoc,
    //             _postTime,
    //             _author,
    //             rating,
    //             _communityId,
    //             _officialReply,
    //             _bestReply,
    //             _deletedReplyCount,
    //             _isDeleted,
    //             _tags,
    //             _properties,
    //             historyVotes,
    //             votedUsers
    //         ) = getPostData(postCollection, 1);

    //         assert!(rating == i64Lib::neg_from(1), 5);
    //         assert!(historyVotes == vector<u8>[1], 13);
    //         assert!(votedUsers == vector<address>[user2], 14);

    //         test_scenario::return_shared(scenario, post_wrapper);
    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };
    // }
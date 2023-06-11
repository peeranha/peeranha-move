#[test_only]
module peeranha::postLib_first_quick_reply_test
{
    use peeranha::postLib::{Self, PostMetaData, Reply};
    use peeranha::postLib_change_post_type_test;
    use sui::test_scenario;
    use sui::clock;

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;

    const UPVOTE_FLAG: bool = true;
    const DOWNVOTE_FLAG: bool = false;

    const START_USER_RATING: u64 = 10;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const USER3: address = @0xA3;

    
    #[test]
    fun test_create_first_reply_to_expert_post() {     //  first/quick reply to expert post
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
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
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

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_reply_to_common_post() {     //  first/quick reply to commom post
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
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
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

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_first_reply_after_delete_previos_reply_to_expert_post() {     //  first/quick reply after delete previous reply to expert post
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
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
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
    fun test_create_first_reply_after_delete_previos_reply_to_common_post() {     //  first/quick reply after delete previous reply to commom post
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
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);
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
    fun test_create_reply_after_create_reply_by_post_author_to_expert_post() {     //  first/quick reply after create reply by post author to expert post
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

        test_scenario::next_tx(scenario, USER2);
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

            assert!(isFirstReply == false, 1);
            assert!(isQuickReply == false, 2);

            test_scenario::return_to_sender(scenario, reply_val);
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

            assert!(isFirstReply == false, 1);
            assert!(isQuickReply == true, 2);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_reply_after_create_reply_by_post_author_to_common_post() {     //  first/quick reply after create reply by post author to expert post
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

        test_scenario::next_tx(scenario, USER2);
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

            assert!(isFirstReply == false, 1);
            assert!(isQuickReply == false, 2);

            test_scenario::return_to_sender(scenario, reply_val);
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

            assert!(isFirstReply == false, 1);
            assert!(isQuickReply == true, 2);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_reply_to_own_post() {
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

        test_scenario::next_tx(scenario, USER2);
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

            assert!(isFirstReply == false, 1);
            assert!(isQuickReply == false, 2);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }
}
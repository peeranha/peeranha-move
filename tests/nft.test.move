#[test_only]
module peeranha::nft_test
{
    use peeranha::userLib_test;
    use peeranha::postLib_test;
    use peeranha::communityLib_test;
    use std::string;
    use sui::url::{Self};
    use sui::vec_map::{Self, VecMap};
    // use peeranha::i64Lib;
    use peeranha::communityLib::{Community};
    use peeranha::achievementLib;
    use peeranha::commonLib;
    use peeranha::nftLib::{Self, AchievementCollection, NFT};
    use peeranha::userLib::{Self, User};
    use peeranha::accessControlLib::{Self, UserRolesCollection};
    use sui::test_scenario::{Self, Scenario};
    use sui::object;
    use peeranha::i64Lib;
    use sui::clock;

    // use std::debug;
    // debug::print(community);

    // TODO: add enum PostType      //export
    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;
    const DOCUMENTATION: u8 = 3;

    const ENGLISH_LANGUAGE: u8 = 0;
    const CHINESE_LANGUAGE: u8 = 1;
    const SPANISH_LANGUAGE: u8 = 2;
    const VIETNAMESE_LANGUAGE: u8 = 3;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const EXTERNAL_URL: vector<u8> = b"https://peeranha.io";

    const ATTRIBUTE_KEY1: vector<u8> = b"attribute key 1";
    const ATTRIBUTE_KEY2: vector<u8> = b"attribute key 2";
    const ATTRIBUTE_VALUE1: vector<u8> = b"attribute value 1";
    const ATTRIBUTE_VALUE2: vector<u8> = b"attribute value 2";


    #[test]
    fun test_create_achievement() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let (
                maxCount,
                factCount,
                lowerBound,
                name,
                description,
                url,
                achievementType,
                communityId,
                externalUrl,
                attributes,
            ) = nftLib::getAchievementData(achievement_collection, 1);

            assert!(maxCount == 15, 1);
            assert!(factCount == 0, 2);
            assert!(lowerBound == 100, 2);
            assert!(name == string::utf8(b"Nft name"), 4);
            assert!(description == string::utf8(b"Nft description"), 5);
            assert!(url == url::new_unsafe_from_bytes(b"ipfs://bafybeiaj4nujwizct37nz5hpne6ltjqh2susaoyaempmsd76qfyns4quhq"), 6);
            assert!(achievementType ==  nftLib::getAchievementTypeRating(), 7);
            assert!(communityId == commonLib::getZeroId(), 7);
            assert!(externalUrl == url::new_unsafe_from_bytes(EXTERNAL_URL), 8);
            assert!(attributes == createAttribytes(), 9);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_community_achievement() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            let community = &mut community_val;

            let (
                maxCount,
                factCount,
                lowerBound,
                name,
                description,
                url,
                achievementType,
                communityId,
                externalUrl,
                attributes,
            ) = nftLib::getAchievementData(achievement_collection, 1);

            assert!(maxCount == 15, 1);
            assert!(factCount == 0, 2);
            assert!(lowerBound == 100, 2);
            assert!(name == string::utf8(b"Nft name"), 4);
            assert!(description == string::utf8(b"Nft description"), 5);
            assert!(url == url::new_unsafe_from_bytes(b"ipfs://bafybeiaj4nujwizct37nz5hpne6ltjqh2susaoyaempmsd76qfyns4quhq"), 6);
            assert!(achievementType ==  nftLib::getAchievementTypeRating(), 7);
            assert!(communityId == object::id(community), 7);
            assert!(externalUrl == url::new_unsafe_from_bytes(EXTERNAL_URL), 8);
            assert!(attributes == createAttribytes(), 9);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    fun test_create_manual_achievement() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_achievement(15, 100, nftLib::getAchievementTypeManual(), scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let (
                maxCount,
                factCount,
                lowerBound,
                name,
                description,
                url,
                achievementType,
                communityId,
                externalUrl,
                attributes,
            ) = nftLib::getAchievementData(achievement_collection, 1);

            assert!(maxCount == 15, 1);
            assert!(factCount == 0, 2);
            assert!(lowerBound == 100, 2);
            assert!(name == string::utf8(b"Nft name"), 4);
            assert!(description == string::utf8(b"Nft description"), 5);
            assert!(url == url::new_unsafe_from_bytes(b"ipfs://bafybeiaj4nujwizct37nz5hpne6ltjqh2susaoyaempmsd76qfyns4quhq"), 6);
            assert!(achievementType ==  nftLib::getAchievementTypeManual(), 7);
            assert!(communityId == commonLib::getZeroId(), 7);
            assert!(externalUrl == url::new_unsafe_from_bytes(EXTERNAL_URL), 8);
            assert!(attributes == createAttribytes(), 9);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_not_limit_count_achievement() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_achievement(0, 100, nftLib::getAchievementTypeRating(), scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let (
                maxCount,
                factCount,
                lowerBound,
                name,
                description,
                url,
                achievementType,
                communityId,
                externalUrl,
                _attributes,
            ) = nftLib::getAchievementData(achievement_collection, 1);

            assert!(maxCount == 0, 1);
            assert!(factCount == 0, 2);
            assert!(lowerBound == 100, 2);
            assert!(name == string::utf8(b"Nft name"), 4);
            assert!(description == string::utf8(b"Nft description"), 5);
            assert!(url == url::new_unsafe_from_bytes(b"ipfs://bafybeiaj4nujwizct37nz5hpne6ltjqh2susaoyaempmsd76qfyns4quhq"), 6);
            assert!(achievementType ==  nftLib::getAchievementTypeRating(), 7);
            assert!(communityId == commonLib::getZeroId(), 7);
            assert!(externalUrl == url::new_unsafe_from_bytes(EXTERNAL_URL), 8);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unlock_common_nft() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let usersNFTIsMinted = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 1);
            assert!(usersNFTIsMinted == false, 7);

            let (
                _maxCount,
                factCount,
                _lowerBound,
                _name,
                _description,
                _url,
                _achievementType,
                _communityId,
                _externalUrl,
                _attributes,
            ) = nftLib::getAchievementData(achievement_collection, 1);
            assert!(factCount == 1, 2);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }
    
    #[test]
    fun test_unlock_manual_nft() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_achievement(15, 100, nftLib::getAchievementTypeManual(), scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &user_val;

            achievementLib::unlockManualNft(
                user_roles_collection,
                achievement_collection,
                user,
                object::id(user),
                1
            );

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let usersNFTIsMinted = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 1);
            assert!(usersNFTIsMinted == false, 7);

            let (
                _maxCount,
                factCount,
                _lowerBound,
                _name,
                _description,
                _url,
                _achievementType,
                _communityId,
                _externalUrl,
                _attributes,
            ) = nftLib::getAchievementData(achievement_collection, 1);
            assert!(factCount == 1, 2);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = nftLib::E_NOT_UNLOCK_ACHIEVEMENT)]
    fun test_try_unlock_common_nft_rating_not_enough() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(5, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let _usersNFTIsMinted = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 1);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_try_unlock_manual_nft_rating_not_enough() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_achievement(15, 100, nftLib::getAchievementTypeManual(), scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &user_val;

            achievementLib::unlockManualNft(
                user_roles_collection,
                achievement_collection,
                user,
                object::id(user),
                1
            );

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let usersNFTIsMinted = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 1);
            assert!(usersNFTIsMinted == false, 7);

            let (
                _maxCount,
                factCount,
                _lowerBound,
                _name,
                _description,
                _url,
                _achievementType,
                _communityId,
                _externalUrl,
                _attributes,
            ) = nftLib::getAchievementData(achievement_collection, 1);
            assert!(factCount == 1, 2);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unlock_2_common_nft() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let usersNFTIsMinted = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 1);
            assert!(usersNFTIsMinted == false, 7);

            let usersNFTIsMinted2 = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 2);
            assert!(usersNFTIsMinted2 == false, 7);

            let (
                _maxCount,
                factCount,
                _lowerBound,
                _name,
                _description,
                _url,
                _achievementType,
                _communityId,
                _externalUrl,
                _attributes,
            ) = nftLib::getAchievementData(achievement_collection, 2);
            assert!(factCount == 1, 5);

            let (
                _maxCount2,
                factCount2,
                _lowerBound2,
                _name2,
                _description2,
                _url2,
                _achievementType2,
                _communityId2,
                _externalUrl,
                _attributes,
            ) = nftLib::getAchievementData(achievement_collection, 1);
            assert!(factCount2 == 1, 4);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unlock_not_limit_count_nft() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_achievement(0, 100, nftLib::getAchievementTypeRating(), scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let usersNFTIsMinted = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 1);
            assert!(usersNFTIsMinted == false, 7);

            let (
                maxCount,
                factCount,
                _lowerBound,
                _name,
                _description,
                _url,
                achievementType,
                _communityId,
                _externalUrl,
                _attributes,
            ) = nftLib::getAchievementData(achievement_collection, 1);
            assert!(maxCount == 0, 5);
            assert!(factCount == 1, 5);
            assert!(achievementType ==  nftLib::getAchievementTypeRating(), 7);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unlock_not_limit_count_manual_nft() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_achievement(0, 15, nftLib::getAchievementTypeManual(), scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &user_val;

            achievementLib::unlockManualNft(
                user_roles_collection,
                achievement_collection,
                user,
                object::id(user),
                1
            );

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let usersNFTIsMinted = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 1);
            assert!(usersNFTIsMinted == false, 7);

            let (
                maxCount,
                factCount,
                _lowerBound,
                _name,
                _description,
                _url,
                _achievementType,
                _communityId,
                _externalUrl,
                _attributes,
            ) = nftLib::getAchievementData(achievement_collection, 1);
            assert!(factCount == 1, 2);
            assert!(maxCount == 0, 3);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_mint_common_nft() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[1], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };
        
        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let user_nft_val = test_scenario::take_from_sender<NFT>(scenario);
            let (
                name,
                description,
                url,
                externalUrl,
                attributes,
                achievementType,
            ) = nftLib::getNftData(&mut user_nft_val);

            assert!(name == string::utf8(b"Nft name"), 4);
            assert!(description == string::utf8(b"Nft description"), 5);
            assert!(url == url::new_unsafe_from_bytes(b"ipfs://bafybeiaj4nujwizct37nz5hpne6ltjqh2susaoyaempmsd76qfyns4quhq"), 6);
            assert!(externalUrl == url::new_unsafe_from_bytes(EXTERNAL_URL), 8);
            assert!(attributes == createAttribytes(), 9);
            assert!(achievementType ==  nftLib::getAchievementTypeRating(), 7);

            let usersNFTIsMinted = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 1);
            assert!(usersNFTIsMinted == true, 7);
            test_scenario::return_to_sender(scenario, user_nft_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = nftLib::E_ALREADY_MINTED)]
    fun test_double_mint_common_nft() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[1], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[1], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_mint_manual_nft() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_achievement(15, 100, nftLib::getAchievementTypeManual(), scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &user_val;

            achievementLib::unlockManualNft(
                user_roles_collection,
                achievement_collection,
                user,
                object::id(user),
                1
            );

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

                test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[1], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };
        
        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let user_nft_val = test_scenario::take_from_sender<NFT>(scenario);
            let (
                name,
                description,
                url,
                externalUrl,
                attributes,
                achievementType,
            ) = nftLib::getNftData(&mut user_nft_val);

            assert!(name == string::utf8(b"Nft name"), 4);
            assert!(description == string::utf8(b"Nft description"), 5);
            assert!(url == url::new_unsafe_from_bytes(b"ipfs://bafybeiaj4nujwizct37nz5hpne6ltjqh2susaoyaempmsd76qfyns4quhq"), 6);
            assert!(externalUrl == url::new_unsafe_from_bytes(EXTERNAL_URL), 8);
            assert!(attributes == createAttribytes(), 9);
            assert!(achievementType ==  nftLib::getAchievementTypeManual(), 7);

            let usersNFTIsMinted = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 1);
            assert!(usersNFTIsMinted == true, 7);
            test_scenario::return_to_sender(scenario, user_nft_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_mint_2_common_nft() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[1], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(10, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[2], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = nftLib::E_ALREADY_MINTED)]
    fun test_mint_2_identical_common_nft() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[1, 1], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_mint_2_common_nft_in_1_transaction() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[1, 2], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;

            let user_nft_val = test_scenario::take_from_sender<NFT>(scenario);
            let (
                name,
                description,
                url,
                externalUrl,
                attributes,
                achievementType,
            ) = nftLib::getNftData(&mut user_nft_val);

            assert!(name == string::utf8(b"Nft name"), 4);
            assert!(description == string::utf8(b"Nft description"), 5);
            assert!(url == url::new_unsafe_from_bytes(b"ipfs://bafybeiaj4nujwizct37nz5hpne6ltjqh2susaoyaempmsd76qfyns4quhq"), 6);
            assert!(externalUrl == url::new_unsafe_from_bytes(EXTERNAL_URL), 8);
            assert!(attributes == createAttribytes(), 9);
            assert!(achievementType ==  nftLib::getAchievementTypeRating(), 7);

            let usersNFTIsMinted = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 1);
            assert!(usersNFTIsMinted == true, 7);

            let user_nft_val2 = test_scenario::take_from_sender<NFT>(scenario);
            let (
                name2,
                description2,
                url2,
                externalUrl2,
                attributes2,
                achievementType2,
            ) = nftLib::getNftData(&mut user_nft_val2);

            assert!(name2 == string::utf8(b"Nft name"), 4);
            assert!(description2 == string::utf8(b"Nft description"), 5);
            assert!(url2 == url::new_unsafe_from_bytes(b"ipfs://bafybeiaj4nujwizct37nz5hpne6ltjqh2susaoyaempmsd76qfyns4quhq"), 6);
            assert!(externalUrl2 == url::new_unsafe_from_bytes(EXTERNAL_URL), 8);
            assert!(attributes2 == createAttribytes(), 9);
            assert!(achievementType2 ==  nftLib::getAchievementTypeRating(), 7);

            let usersNFTIsMinted2 = nftLib::getUsersNFTIsMinted(achievement_collection, object::id(&mut user_val), 2);
            assert!(usersNFTIsMinted2 == true, 7);

            test_scenario::return_to_sender(scenario, user_nft_val);
            test_scenario::return_to_sender(scenario, user_nft_val2);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = nftLib::E_ACHIEVEMENT_NOT_EXIST)]
    fun test_mint_2_common_nft_in_1_transaction_1_nft_does_not_exist() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[1, 2], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = nftLib::E_ALREADY_MINTED)]
    fun test_mint_2_common_nft_in_1_transaction_1_nft_already_minted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[1], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[2, 1], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = nftLib::E_NOT_UNLOCK_ACHIEVEMENT)]
    fun test_mint_2_common_nft_in_1_transaction_1_can_not() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_nft_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_standart_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_achievement(15, 300, nftLib::getAchievementTypeManual(), scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let achievement_collection = &mut achievement_collection_val;
            achievementLib::mintUserNFT(achievement_collection, &mut user_val, vector<u64>[1, 2], test_scenario::ctx(scenario));
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }


    // ====== Support functions ======

    #[test_only]
    public fun createAttribytes(): VecMap<string::String, string::String> {
        let attributes = vec_map::empty();
        vec_map::insert(&mut attributes, string::utf8(ATTRIBUTE_KEY1), string::utf8(ATTRIBUTE_VALUE1));
        vec_map::insert(&mut attributes, string::utf8(ATTRIBUTE_KEY2), string::utf8(ATTRIBUTE_VALUE2));
        attributes
    }

    #[test_only]
    public fun init_nft_test(scenario: &mut Scenario): clock::Clock {
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

        time
    }

    #[test_only]
    public fun create_standart_achievement(scenario: &mut Scenario) {
        create_achievement(15, 100, nftLib::getAchievementTypeRating(), scenario);
    }

    #[test_only]
    public fun create_standart_manual_achievement(scenario: &mut Scenario) {
        create_achievement(15, 100, nftLib::getAchievementTypeManual(), scenario);
    }

    #[test_only]
    public fun create_community_standart_achievement(scenario: &mut Scenario) {
        let community_val = test_scenario::take_shared<Community>(scenario);
        create_community_achievement(&mut community_val, 15, 100, nftLib::getAchievementTypeRating(), scenario);
        test_scenario::return_shared(community_val);
    }

    #[test_only]
    public fun create_achievement(maxCount: u32, lowerBound: u64, achievementType: u8, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
        let achievement_collection = &mut achievement_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;

        achievementLib::configureAchievement(
            user_roles_collection,
            achievement_collection,
            user,
            maxCount,
            lowerBound,
            string::utf8(b"Nft name"),
            string::utf8(b"Nft description"),
            b"ipfs://bafybeiaj4nujwizct37nz5hpne6ltjqh2susaoyaempmsd76qfyns4quhq",
            achievementType,
            EXTERNAL_URL,
            vector<string::String>[string::utf8(ATTRIBUTE_KEY1), string::utf8(ATTRIBUTE_KEY2)],
            vector<string::String>[string::utf8(ATTRIBUTE_VALUE1), string::utf8(ATTRIBUTE_VALUE2)],
            test_scenario::ctx(scenario),
        );

        postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun create_community_achievement(community: &mut Community, maxCount: u32, lowerBound: u64, achievementType: u8, scenario: &mut Scenario) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let achievement_collection_val = test_scenario::take_shared<AchievementCollection>(scenario);
        let achievement_collection = &mut achievement_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;

        achievementLib::configureCommunityAchievement(
            user_roles_collection,
            achievement_collection,
            user,
            community,
            maxCount,
            lowerBound,
            string::utf8(b"Nft name"),
            string::utf8(b"Nft description"),
            b"ipfs://bafybeiaj4nujwizct37nz5hpne6ltjqh2susaoyaempmsd76qfyns4quhq",
            achievementType,
            EXTERNAL_URL,
            vector<string::String>[string::utf8(ATTRIBUTE_KEY1), string::utf8(ATTRIBUTE_KEY2)],
            vector<string::String>[string::utf8(ATTRIBUTE_VALUE1), string::utf8(ATTRIBUTE_VALUE2)],
            test_scenario::ctx(scenario),
        );

        test_scenario::return_shared(user_roles_collection_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(achievement_collection_val);
    }

    #[test_only]
    public fun unlock_standart_manual_achievement(scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
        let achievement_collection = &mut achievement_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &user_val;

        achievementLib::unlockManualNft(
            user_roles_collection,
            achievement_collection,
            user,
            object::id(user),
            1
        );

        postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    public fun updateRating(changeRating: u64, isPositive: bool, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
        let achievement_collection = &mut achievement_collection_val;
        let userId = object::id(&mut user_val);
        let user_rating_collection = &mut user_rating_collection_val;
        let community = &mut community_val;
        userLib::updateRating_test(
            user_rating_collection,
            userId,
            achievement_collection,
            if(isPositive) i64Lib::from(changeRating) else i64Lib::neg_from(changeRating),
            object::id(community),
            test_scenario::ctx(scenario),
        );

        postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }
}
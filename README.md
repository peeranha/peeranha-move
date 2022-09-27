
Error code:

    User

10 - user does not exist
11 - already_followed
12 - comm_not_followed

    Community

20 - Require at least 5 tags

21 - Require tags with unique names

22 - Community does not exist

23 - Community is frozen

24 - Wrong tag id

25 - The community does not have tag with 0 id.

26 - At least one tag is required.

    Common

30 - Invalid_ipfsHash

31 - Invalid_post_type

32 - invalid_resource_type

    Post
40 - Wrong item ID

41 - Users can not publish 2 replies for expert and common posts.

42 - You can not edit this post. It is not your.

43 - You can not edit this Reply. It is not your.

44 - You can not edit this comment. It is not your.

45 - You can not delete the best reply.

46 - You can not publish replies in tutorial or Documentation.

47 - User is forbidden to reply on reply for Expert and Common type of posts

48 - You can not publish comments in Documentation.

49 - This post type is already set.

50 - Error_postType

51 - error_vote_comment

52 - error_vote_reply

53 - error_vote_post

54 - You can not vote to Documentation.

owner - 0x62a5541796a4fa35229543da71df4f570f7cbe02
package object ID - 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0
user object - 0x94e98b7c4f229e5011fffbb1778e2a03003aac5f
community - 0xf67fdeab0355f72438df93c11bff68eb3c538e43
post - 0xb5d76295c7010d60f9a50c18a965a2cf586f29ff


sui client publish --path ./ --gas-budget 30000

createUser - sui client call --function createUser --module userLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0x94e98b7c4f229e5011fffbb1778e2a03003aac5f\" \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" \"x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1"\" --gas-budget 30000

updateUser - sui client call --function updateUser --module userLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0x94e98b7c4f229e5011fffbb1778e2a03003aac5f\" \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" \"x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82"\" --gas-budget 30000

createCommunity - sui client call --function createCommunity --module communityLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0xf67fdeab0355f72438df93c11bff68eb3c538e43\" \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" \"x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6"\" \[\"0x0000000000000000000000000000000000000000000000000000000000000001\",\"0x0000000000000000000000000000000000000000000000000000000000000002\",\"0x0000000000000000000000000000000000000000000000000000000000000003\",\"0x0000000000000000000000000000000000000000000000000000000000000004\",\"0x0000000000000000000000000000000000000000000000000000000000000005\"\] --gas-budget 30000

updateCommunity - sui client call --function updateCommunity --module communityLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0xf67fdeab0355f72438df93c11bff68eb3c538e43\" 0 \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" \"x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82"\" --gas-budget 30000

createTag - sui client call --function createTag --module communityLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0xf67fdeab0355f72438df93c11bff68eb3c538e43\" 0 \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" \"x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1"\" --gas-budget 30000

updateTag - sui client call --function updateTag --module communityLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0xf67fdeab0355f72438df93c11bff68eb3c538e43\" 0 2 \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" \"x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1"\" --gas-budget 30000

freezeCommunity - sui client call --function freezeCommunity --module communityLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0xf67fdeab0355f72438df93c11bff68eb3c538e43\" 0 \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" --gas-budget 30000

unfreezeCommmunity - sui client call --function unfreezeCommmunity --module communityLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0xf67fdeab0355f72438df93c11bff68eb3c538e43\" 0 \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" --gas-budget 30000

createPost - sui client call --function createPost --module postLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0xb5d76295c7010d60f9a50c18a965a2cf586f29ff\" \"0xf67fdeab0355f72438df93c11bff68eb3c538e43\" \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" 0 \"x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc"\" \[1,3\] --gas-budget 30000

editPost - sui client call --function editPost --module postLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0xb5d76295c7010d60f9a50c18a965a2cf586f29ff\" \"0xf67fdeab0355f72438df93c11bff68eb3c538e43\" \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" 1 \"x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82"\" \[1,4\] --gas-budget 30000






<!-- deletePost - sui client call --function deletePost --module postLib --package 0x53e642709cab2b2f8d04c3041a5325a0657bb3d0 --args \"0xb5d76295c7010d60f9a50c18a965a2cf586f29ff\" \"0x62a5541796a4fa35229543da71df4f570f7cbe02\" 1 --gas-budget 30000 -->


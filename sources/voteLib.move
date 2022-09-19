module basics::voteLib {

//     struct StructRating has copy,store{
//         upvotedPost: u64,
//         downvotedPost: u64,

//         upvotedReply: u64,
//         downvotedReply: u64,
//         firstReply: u64,
//         quickReply: u64,
//         acceptReply: u64,
//         acceptedReply: u64
//     }

//     public fun getExpertRating(): StructRating {
//         StructRating {
//             upvotedPost: UPVOTED_EXPERT_POST,
//             downvotedPost: DOWNVOTED_EXPERT_POST,

//             upvotedReply: UPVOTED_EXPERT_REPLY,
//             downvotedReply: DOWNVOTED_EXPERT_REPLY,
//             firstReply: FIRST_EXPERT_REPLY,
//             quickReply: QUICK_EXPERT_REPLY,
//             acceptReply: ACCEPT_EXPERT_REPLY,
//             acceptedReply: ACCEPTED_EXPERT_REPLY
//         }
//     }

//     public fun getCommonRating(): StructRating {
//         StructRating {
//             upvotedPost: UPVOTED_COMMON_POST,
//             downvotedPost: DOWNVOTED_COMMON_POST,

//             upvotedReply: UPVOTED_COMMON_REPLY,
//             downvotedReply: DOWNVOTED_COMMON_REPLY,
//             firstReply: FIRST_COMMON_REPLY,
//             quickReply: QUICK_COMMON_REPLY,
//             acceptReply: ACCEPT_COMMON_REPLY,
//             acceptedReply: ACCEPTED_COMMON_REPLY
//         }
//     }

//     public fun getTutorialRating(): StructRating {
//         StructRating {
//             upvotedPost: UPVOTED_TUTORIAL,
//             downvotedPost: DOWNVOTED_TUTORIAL,

//             upvotedReply: 0,
//             downvotedReply: 0,
//             firstReply: 0,
//             quickReply: 0,
//             acceptReply: 0,
//             acceptedReply: 0
//         }
//     }


//     //expert post
//     const DOWNVOT_EXPERT_POST: u64 = 100000 - 1;
//     const UPVOTED_EXPERT_POST: u64 = 100000 + 5;
//     const DOWNVOTED_EXPERT_POST: u64 = 100000 - 2;

//     //common post 
//     const DOWNVOTE_COMMON_POST: u64 = 100000 - 1;
//     const UPVOTED_COMMON_POST: u64 = 100000 + 1;
//     const DOWNVOTED_COMMON_POST: u64 = 100000 - 1;

//     //tutorial 
//     const DOWNVOTE_TUTORIAL: u64 = 100000 - 1;
//     const UPVOTED_TUTORIAL: u64 = 100000 + 5;
//     const DOWNVOTED_TUTORIAL: u64 = 100000 - 2;

//     const DELETE_OWN_POST: u64 = 100000 - 1;
//     const MODERATOR_DELETE_POST: u64 = 100000 - 2;

// /////////////////////////////////////////////////////////////////////////////

//     //expert reply
//     const DOWNVOTE_EXPERT_REPLY: u64 = 100000 - 1;
//     const UPVOTED_EXPERT_REPLY: u64 = 100000 + 10;
//     const DOWNVOTED_EXPERT_REPLY: u64 = 100000 - 2;
//     const ACCEPT_EXPERT_REPLY: u64 = 100000 + 15;
//     const ACCEPTED_EXPERT_REPLY: u64 = 100000 + 2;
//     const FIRST_EXPERT_REPLY: u64 = 100000 + 5;
//     const QUICK_EXPERT_REPLY: u64 = 100000 + 5;

//     //common reply 
//     const DOWNVOTE_COMMON_REPLY: u64 = 100000 - 1;
//     const UPVOTED_COMMON_REPLY: u64 = 100000 + 1;
//     const DOWNVOTED_COMMON_REPLY: u64 = 100000- 1;
//     const ACCEPT_COMMON_REPLY: u64 = 100000 + 3;
//     const ACCEPTED_COMMON_REPLY: u64 = 100000 + 1;
//     const FIRST_COMMON_REPLY: u64 = 100000 + 1;
//     const QUICK_COMMON_REPLY: u64 = 100000 + 1;
    
//     const DELETE_OWN_REPLY: u64 = 100000 - 1;
//     const MODERATOR_DELETE_REPLY: u64 = 100000 - 2;            // to do

// /////////////////////////////////////////////////////////////////////////////////

//     const MODERATOR_DELETE_COMMENT: u64 = 100000 - 1;
}
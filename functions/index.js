const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onFollowUser = functions.firestore.document("/followers/{userId}/usersFollowers/{followerId}")
.onCreate(async (snapshot, context) => {
    console.log(snapshot.data());
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const followedUserPosts = admin.firestore().collection("posts").doc(userId).collection("userPosts");
    const followedUserPostsSnapshot = await followedUserPosts.get();

    const userFeedRef = admin.firestore().collection("feeds").doc(followerId).collection("usersFeeds");
    followedUserPostsSnapshot.forEach(doc=>{
        
        userFeedRef.doc(doc.id).set(doc.data());
    });
    
});

exports.onUnfollowUser = functions.firestore.document("/followers/{userId}/usersFollowers/{followerId}").onDelete(async (snapshot,context)=>{
       const userId = context.params.userId;
       const followerId = context.params.followerId;

       const userFeedRef = admin.firestore().collection("feeds").doc(followerId).collection("usersFeeds").where("authorId","==",userId);

       const userFeedSnapshot = await userFeedRef.get();

       userFeedSnapshot.forEach(doc => {
           if(doc.exists){
               doc.ref.delete();
           }
       });

});


exports.onUploadPost = functions.firestore.document("/posts/{userId}/userPosts/{postId}").onCreate(async (snapshot,context)=>{
    const userId = context.params.userId;
    const postId = context.params.postId;
    
    const usersFollowersRef = admin.firestore().collection("followers").doc(userId).collection("usersFollowers");
    const usersFollowersSnapshot = await usersFollowersRef.get();

    usersFollowersSnapshot.forEach(doc =>{
        admin.firestore().collection("feeds").doc(doc.id).collection("usersFeeds").doc(postId).set(snapshot.data())
    });


});

exports.onUpdatePost = functions.firestore.document("/posts/{userId}/userPosts/{postId}").onUpdate(async (snapshot,context)=>{

    const userId = context.params.userId;
    const postId = context.params.postId;
    const updatedPostData = snapshot.after.data();

    const userFollowersRef = admin.firestore().collection("followers").doc(userId).collection("usersFollowers");
    const usersFollowersSnapshot = await userFollowersRef.get();
    
    usersFollowersSnapshot.forEach(async doc=>{
        const userFeedRef = admin.firestore().collection("feeds").doc(doc.id).collection("usersFeeds");
        const userFeedSnapshot = await userFeedRef.doc(postId).get();
        if(userFeedSnapshot.exists){
            userFeedSnapshot.ref.update(updatedPostData);
        }
    })

})
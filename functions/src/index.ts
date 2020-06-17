import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';


admin.initializeApp();


export const onConversationCreated = functions.firestore.document("Conversations/{chatID}").onCreate(async(snapshot,context)=>{
    let data = snapshot.data();
    let chatID = context.params.chatID;
    if(data){
        let members = data.members;
        for(let index =0;index <= members.length;index++){
            let currentUserID = members[index];
            let remainingUserIDs = members.filter((u: string)=> u != currentUserID);
            remainingUserIDs.forEach((m: string)=>{
                 return admin.firestore().collection("Users").doc(m).get().then((_doc)=>{
                     let userData = _doc.data();
                     if(userData){
                        return admin.firestore().collection('Users').doc(currentUserID).collection('Conversations').doc(m).create({
                            "chatID":chatID,
                            "image":userData.image,
                            "name":userData.name,
                            "unseenCount":1
                        });
                     }
                     return null;
                 }).catch(()=>{return null});;
            });

        }
    }
    return null;
});



export const onConversationUpdated = functions.firestore.document("Conversations/{chatID}").onUpdate((change,context)=>{
    let data = change.after.data();
    if(data){
        let members = data.members;
        let lastMessage = data.messages[data.messages.length - 1];

        for(let index = 0;index<members.length;index++){
            let currentUserID = members[index];
            let remainingUserIDs = members.filter((u: string)=> u != currentUserID);
            remainingUserIDs.forEach((u: string)=>{
                return admin.firestore().collection("Users").doc(currentUserID).collection("Conversations").doc(u).update({
                    "lastMessage": lastMessage.message,
                    "timestamp":lastMessage.timestamp,
                    "unseenCount":admin.firestore.FieldValue.increment(1),
                });
            });
        }
    }
    return null;
});

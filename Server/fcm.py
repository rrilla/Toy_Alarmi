from data import Jira
from data import Site
from typing import List

import firebase_admin
from firebase_admin import firestore
from firebase_admin import credentials
from firebase_admin import messaging
from google.cloud.firestore_v1.base_query import FieldFilter

class Fcm:
    # cred = credentials.Certificate("./key/benest.json")
    _cred = credentials.Certificate("D:/hjh/workspace/Toy_Alarmi/Server/key/firebase_key.json")
    _app = firebase_admin.initialize_app(_cred)
    db = firestore.client()

    # def getMessage(self, site: Site, newIssue: List[Jira]):

    
    def getToken(self, site: Site):
        sub_ref = self.db.collection("subscription").where(filter=FieldFilter("siteId", "==", site.id))
        docs = sub_ref.stream()

        users = []
        for doc in docs:
            # print(doc.to_dict().get("token"))
            # tokens.append(doc.to_dict().get("token"))
            print(doc.to_dict())
            users.append(doc.to_dict().get("userId"))
        # print(f"{doc.id} => {doc.to_dict().get('token')}")
        print(users)

        user_ref = self.db.collection("user").where(filter=FieldFilter("id", "in", users))
        docs2 = user_ref.stream()

        tokens = []
        for doc in docs2:
            tokens.append(doc.to_dict().get("token"))
            print(doc.to_dict().get("token"))

        return tokens

    def sendFCM(self, site: Site, newIssue: List[Jira]):
        issueCount = len(newIssue)
        tokens = self.getToken(site)
        title = '신규 이슈 알림. ({0}건)'.format(issueCount)
        body = []
        body.append("[{0} - {1}] {2} - 담당자 : {3}".format(site.name, newIssue[0].urgency, newIssue[0].title, newIssue[0].manager))
        if (issueCount != 1):
            print("들어왔다")
            body.append(" 외 {0}건".format(issueCount-1))
        body = ''.join(body)
        
        message = messaging.MulticastMessage(
            notification= messaging.Notification(
                title = title,
                body = body,
                image = site.image
            ),
            android= messaging.AndroidConfig(
                priority='high'
            ),
            data={
                'score': '850',
                'time': '2:45',
            },
            tokens=tokens
        )

        response = messaging.send_multicast(message)
        print('{0} messages were sent successfully \n title : {1}\n body : {2}'.format(response.success_count, title, body))
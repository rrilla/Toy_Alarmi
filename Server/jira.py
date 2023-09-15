import requests
import time
import pymysql
import re
import datetime
import os
import firebase_admin
from typing import List
from data import Jira
from data import Site
from firebase_admin import credentials
from firebase_admin import messaging
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from fake_useragent import UserAgent

cookie = {
    "ajs_anonymous_id" : "%2220b9b755-7279-4264-a76e-a565399e283b%22",
    "atlassian.xsrf.token" : "6d78d611-d912-4f2b-8719-d180e682a3f4_ef662778bcc83847095acea8e2a41d2b7747f2d9_lin",
    "atlassian.account.xsrf.token" : "e5795d3c-d7d3-40ed-aaee-911eeb3aad46",
    "io" : "Q7uuy3Ao_FXmJP4GAZA8",
    "JSESSIONID":"364274FE46BF4E613FB18057F0D4FFBA",
    "tenant.session.token" : "eyJraWQiOiJzZXNzaW9uLXNlcnZpY2VcL3Byb2QtMTU5Mjg1ODM5NCIsImFsZyI6IlJTMjU2In0.eyJhc3NvY2lhdGlvbnMiOltdLCJzdWIiOiI2MjY3OGRmMDE4NWFjMjAwNjkzMDkwMmQiLCJlbWFpbERvbWFpbiI6ImZpeGVsc29mdC5jb20iLCJpbXBlcnNvbmF0aW9uIjpbXSwiY3JlYXRlZCI6MTY5NDEzMTI1MSwicmVmcmVzaFRpbWVvdXQiOjE2OTQ0ODQyNzQsInZlcmlmaWVkIjp0cnVlLCJpc3MiOiJzZXNzaW9uLXNlcnZpY2UiLCJzZXNzaW9uSWQiOiI4Njc0M2ZjOS0yYWY1LTQ5OGYtOGQ2OS1iNDM4Y2E3YzU1OGIiLCJzdGVwVXBzIjpbXSwiYXVkIjoiYXRsYXNzaWFuIiwibmJmIjoxNjk0NDgzNjc0LCJleHAiOjE2OTcwNzU2NzQsImlhdCI6MTY5NDQ4MzY3NCwiZW1haWwiOiJoamg5NEBmaXhlbHNvZnQuY29tIiwianRpIjoiODY3NDNmYzktMmFmNS00OThmLThkNjktYjQzOGNhN2M1NThiIn0.OKbiMnnTm482-sB1gaApo1usmTKbflJw7g803Ktd35SL110mFfMrAEFdCjwSFOvrpvKeQr2ppig2USfuk4wHMmy7s-G4lhvpIMi89npAAErYfv_MReGGm8dq9pzo1LJJjdn4ALbDKkG7q56F3-uuYjmd2FC0zp0Gih2JKg2cuiH9C6ZoanJ-l0RAWZcf7REdrqfX_NZnDQtLnnGlw9WeeuJR4Onm_1RMM_nkqZlPUp3mXrjlrXiyivhdrb5DQpfkQdOT7f89t1f_mhGOue9Z4v1ujJz-8dHpt3ZhsUZ03uUdUou7fMsNEzmlyZkhh2_anIe6-RIF-oewJrkit6XmUg"
}
ua = UserAgent()
headers = {'User-Agent' : ua.random}

conn = pymysql.connect(
    charset='utf8',
    user='root', 
    passwd='aA11111!', 
    host='127.0.0.1',
    db='crawling'
)
cursor = conn.cursor()


# 기존 data 삭제, 새로운 데이터 추가
def init(result: List[Site]):
    cursor.execute("DELETE FROM crawling.data")
    cursor.execute("ALTER TABLE crawling.data AUTO_INCREMENT = 1")
    conn.commit()

    for res in result:
        crawlingData = crawlingIssue(res)
        insertIssue(crawlingData)

# 신규 이슈 여부 확인 및 존재 시 insert
def trackingIssue(result: List[Site]):

    for res in result:
        crawlingData = crawlingIssue(res)
        isNew = isNewIssue(crawlingData, res)
        # if (isNew):
        #     cursor.execute("DELETE FROM crawling.data Where site_id=%s", (res[0]))
        #     conn.commit()
        #     insertIssue(crawlingData)

# 새로운 issue 있는지 체크.
def isNewIssue(crawlingData: List[Jira], site: Site):
    try:
        cursor.execute("SELECT * FROM crawling.data WHERE site_id=%s", (site.id))
        dbData: List[Jira] = []
        for i in cursor.fetchall():
            dbData.append(Jira(*i))
    # db key == crawlingData key 비교.
        if (dbData[-1].key == crawlingData[-1].key):
            print("'{0}' 프로젝트 새로운 issue 없음.".format(site.name))
            # print("마지막 값 같음.", dbData[-1][2], crawlingData[-1][1])
            return False
        else:
            newIssue: List[Jira] = []
            lastIssue: Jira = dbData[-1]
            print("'{0}' 프로젝트 새로운 issue 있음.".format(site.name))
            crawlingData.reverse()
            for data in crawlingData:
                if (data.key != lastIssue.key):
                    newIssue.append(data)
                else:
                    break
            
            newIssue.reverse()
            insertIssue(newIssue)

            # title = "신규 이벤트"
            # message = "{0} 담당자 : {0}, 긴급도 : {1}\n {2}[{3}]".format(item.)
            
            sendFCM(siteName, newIssue)
            # for item in newIssue:
            #     print("신규이슈 - project : {0}, key : {1}, title : {2}".format(site.name, item.key, item.title))

            # 추가된 이슈 분류 및 알림 전송.
            return True
        
    except Exception as e:
        print("isNewIssue() 실패.", e)
        return False

# 크롤링 이슈 DB 저장.
def insertIssue(crawlingData: List[Jira]):
    inesrt_sql = "INSERT INTO crawling.data (`site_id`, `key`, `title`, `manager`, `repoter`, `urgency`, `status`) VALUES(%s, %s, %s, %s, %s, %s, %s)"
    # inesrt_sql = "INSERT INTO crawling.data VALUES(%s, %s, %s, %s, %s, %s, %s, %s)"
    insert_data = []
    for i in crawlingData:
        insert_data.append((i.site_id, i.key, i.title, i.manager, i.repoter, i.urgency, i.status))
    cursor.executemany(inesrt_sql, insert_data)
    conn.commit()

# 이슈 크롤링.
def crawlingIssue(site: Site):

    print(site.url)
    response = requests.get(site.url, headers=headers, cookies=cookie)
    time.sleep(2)

    if response.status_code == 200:
        html = response.content.decode('utf-8','replace')
        soup = BeautifulSoup(html, 'html.parser')
        # tbody = soup.find('tbody', attrs={"class": "_n7zlglyw"})
        tbody = soup.find('tbody')
        
        crawlingData: List[Jira] = []

        for tr in tbody.find_all("tr"):
            key = tr.select_one("td:nth-child(2) > div > div > a").text
            title = tr.select_one("td:nth-child(3) > div > a").text
            manager = tr.select_one("td:nth-child(4) > div > span").text
            repoter = tr.select_one("td:nth-child(5) > div > span").text
            urgency = tr.select_one("td:nth-child(6) > div > img")['alt']
            status = tr.select_one("td:nth-child(7) > div").text

            crawlingData.append(Jira(None, site.id, key, title, manager, repoter, urgency, status))
            # print("key : {0}, title : {1}, manager : {2}, repoter : {3}, urgency : {4}, status : {5}".format(key, title, manager, repoter, urgency, status))
        
        crawlingData.reverse()
        print("크롤링 성공 - site_id : {0}, name : {1}, url : {2}".format(site.id, site.name, site.url))

    else :
        print("크롤링 실패 : site_id : {0}, name : {1}, url : {2} \n 상태코드 : ${3}".format(site.id, site.name, site.url, response.status_code))

    return crawlingData

def sendFCM(siteName, items):
    # cred = credentials.Certificate("./firebase_key.json")
    cred = credentials.Certificate("./key/benest.json")
    firebase_admin.initialize_app(cred)

    message = messaging.Message(
        notification= messaging.Notification(
            title = 'noti title',
            body = 'noti body..',
            image = 'https://imagescdn.gettyimagesbank.com/500/23/158/025/0/1463022977.jpg'
        ),
        data={
            'score': '850',
            'time': '2:45',
        },
        token=token,
    )

    response = messaging.send(message)
    print('Successfully sent message:', response)

def sendFCMs(tokens):
    # cred = credentials.Certificate("./firebase_key.json")
    cred = credentials.Certificate("./benest.json")
    firebase_admin.initialize_app(cred)

    message = messaging.Message(
        notification= messaging.Notification(
            title = 'noti title',
            body = 'noti body..',
            image = 'https://imagescdn.gettyimagesbank.com/500/23/158/025/0/1463022977.jpg'
        ),
        data={
            'score': '850',
            'time': '2:45',
        },
        tokens=tokens,
    )

    response = messaging.send_multicast(message)
    print('{0} messages were sent successfully'.format(response.success_count))

try:
    cursor.execute("SELECT * FROM site;")
    result: List[Site] = []
    for res in cursor.fetchall():
        result.append(Site(*res))

    
    # dataJira()
    # cursor.fet
    # for zz in dd:
    #     dataJira.append(Jira(zz[0],zz[1],zz[2],zz[3],zz[4],zz[5],zz[6],zz[7]))

    print(result)
    # init(result)
    trackingIssue(result)
    # sendFCM("fAc-0A0NQIag6gltaZSFZ-:APA91bGl8cjhPJw1KqgoMlmGQXktPJmu1KFO5Zo0yDpamHRhhsfxurJ_BwgUxDsxjcuSKotWKVGTWuGr3xfto86-7Rg1earVft1miy1PVIdTYnfUNohl5GZR4qdbjPh1YaxRjxeBd8n_")
except Exception as e:
    print("init() 실패", e)
finally:
    conn.close()



    

# 알림 보내기
# def sendPush():

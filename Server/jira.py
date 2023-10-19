import requests
import json
import time
import pymysql
# import re
# import datetime
# import os
# import firebase_admin
from typing import List
from data import Jira
from data import Site
from fcm import Fcm
# from firebase_admin import credentials
# from firebase_admin import messaging
from bs4 import BeautifulSoup
# from selenium import webdriver
# from selenium.webdriver.common.by import By
# from selenium.webdriver.common.keys import Keys
# from selenium.webdriver.common.action_chains import ActionChains
from fake_useragent import UserAgent

fcm = Fcm()
jira_file_path = "./key/jira.json"
jira_file_path = "D:\hjh\workspace\Toy_Alarmi\Server\key\jira.json"
with open(jira_file_path, 'r') as file:
    jiraData = json.load(file)

cookie = {
    "ajs_anonymous_id" : jiraData['ajs_anonymous_id'],
    "atlassian.xsrf.token" : jiraData['atlassian_xsrf_token'],
    "atlassian.account.xsrf.token" : jiraData['atlassian_account_xsrf_token'],
    "io" : jiraData['io'],
    "JSESSIONID":jiraData['JSESSIONID'],
    "tenant.session.token" : jiraData['tenant_session_token'],
}


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

            Fcm.sendFCM(fcm, site, newIssue)

            # title = "신규 이벤트"
            # message = "{0} 담당자 : {0}, 긴급도 : {1}\n {2}[{3}]".format(item.)
            
            # sendFCM(siteName, newIssue)
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

    # ua = UserAgent()
    # headers = {'User-Agent' : ua.random}
    print(site.url)
    # response = requests.get(site.url, headers=headers, cookies=cookie)
    response = requests.get(site.url, cookies=cookie)
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


try:
    # cursor.execute("SELECT * FROM site")
    result: List[Site] = []
    docs = fcm.db.collection("site").stream()

    for doc in docs:
        print(doc.to_dict())
        val = doc.to_dict()
        result.append(Site(id=val.get('id'), name=val.get('name'), url=val.get('url'), image=val.get('image')))

    # cursor.execute("SELECT * FROM site WHERE id='1';")
    # result: List[Site] = []
    # for res in cursor.fetchall():
    #     result.append(Site(*res))

    
    # dataJira()
    # cursor.fet
    # for zz in dd:
    #     dataJira.append(Jira(zz[0],zz[1],zz[2],zz[3],zz[4],zz[5],zz[6],zz[7]))

    print(result)
    # print()
    # dd = result[0]
    # Fcm.sendFCM(Fcm(), dd)
    # init(result)
    trackingIssue(result)
except Exception as e:
    print("init() 실패", e)
finally:
    conn.close()



    

# 알림 보내기
# def sendPush():

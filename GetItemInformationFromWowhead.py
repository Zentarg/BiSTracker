import requests
import json
import sys, getopt, os
from bs4 import BeautifulSoup

scriptName = "GetItemInformationFromWowhead.py"

URL = 'https://www.wowhead.com/wotlk/item='
QuestCaregoryUrl = 'https://www.wowhead.com/wotlk/quests='
QuestUrl = 'https://www.wowhead.com/wotlk/quest='
ZoneUrl = 'https://www.wowhead.com/wotlk/zone='

SCRIPT_START = "var tabsRelated"# = new Tabs({parent: WH.ge('jkbfksdbl4')"#, trackable: 'Item'});"
DATA_START = 'data:'

path = './AllItems'

class Item:
    def __init__(self, id, name, dropID, sourceName, sourceType, dropChance, zone):
        self.ID = id
        self.Name = name
        self.Source = {}
        self.Source["ID"] = dropID
        self.Source["SourceName"] = sourceName
        self.Source["SourceType"] = sourceType
        self.Source["DropChance"] = dropChance
        self.Source["Zone"] = zone

    def toJson(self):
        return json.dumps(self, default=lambda o: o.__dict__)
    def toLuaTable(self):
        string = "{id=" + str(self.ID) + ","
        string += "name=\"" + self.Name.replace('"', '\\"') + "\","
        string += "source={"
        string += "ID=" + str(self.Source["ID"]) + ","
        string += "SourceName=\"" + str(self.Source["SourceName"]).replace('"', '\\"') + "\","
        string += "SourceType=\"" + self.Source["SourceType"] + "\","
        string += "DropChance=\"" + str(self.Source["DropChance"]) + "\","
        string += "Zone=\"" + self.Source["Zone"].replace('"', '\\"') + "\""
        string += "}}"
        return string
    
def get_region(content, start, end = None):
    idx_s = content.index(start)
    idx_e = len(content)
    if end:
        idx_e = content.index(end, idx_s)
    return content[idx_s + len(start): idx_e]

def GetZone(zoneID):
    zUrl = ZoneUrl + str(zoneID)
    pageZone = requests.get(zUrl)
    soupZone = BeautifulSoup(pageZone.content, 'html.parser')
    zoneNameH1 = soupZone.find('h1', class_='heading-size-1')
    zoneName = zoneNameH1.text
    return zoneName

def GetCategory(categoryID, category2ID):
    cUrl = QuestCaregoryUrl + str(category2ID) + "." + str(categoryID)
    pageCat = requests.get(cUrl)
    soupCat = BeautifulSoup(pageCat.content, 'html.parser')
    CatNameH1 = soupCat.find('h1', class_='heading-size-1')
    zoneName = CatNameH1.text.replace(" Quests", "")
    return zoneName

def GetName(scripts, scriptStart, dataStart, dataEnd):
    data_container = None
    for child in scripts:
        content = ''.join(child.contents).replace('\n   ', '').strip()
        if content.startswith(scriptStart):
            data_container = content
            break
    r0 = get_region(data_container, dataStart)
    r1 = get_region(r0, ' ', dataEnd)
    return r1[9:]

def GetQuestName(questID):
    qUrl = QuestUrl + str(questID)
    pageCat = requests.get(qUrl)
    soupCat = BeautifulSoup(pageCat.content, 'html.parser')
    CatNameH1 = soupCat.find('h1', class_='heading-size-1')
    questName = CatNameH1.text
    return questName

def truncate(n, decimals=0):
    multiplier = 10 ** decimals
    return int(n * multiplier) / multiplier

def GetItem(itemID, itemName = ''):
    if (itemID == 0):
        return Item(itemID, itemName, 0, "", False, False, 0, False, 0, 0, "")
    data_container = None
    url = URL + str(itemID)
    page = requests.get(url)
    soup = BeautifulSoup(page.content, 'html.parser')

    twitterTitle = soup.find("meta", property="twitter:title", content=True)
    if (twitterTitle is not None):
        itemName = twitterTitle['content']
    else:
        ogTitle = soup.find("meta", property="og:title", content=True)
        if (ogTitle is not None):
            itemName = ogTitle['content']
        else:
            pageTitle = soup.find("title", content=True)
            if (pageTitle is not None):
                itemName = pageTitle.split("-")[0].strip()

    o = Item(itemID, itemName, 0, "", "Unknown", 0, "")

    main = soup.find(id='main-contents')
    scripts = main.findAll('script')
    for child in scripts:
        content = ''.join(child.contents).replace('\n   ', '').strip()
        if content.startswith(SCRIPT_START):
            data_container = content
            if (len(content) < 80):
                return o
            break
    if (data_container == None or not DATA_START in data_container):
        print("Could not find script data")
        return o
    
    r0 = get_region(data_container, DATA_START)
    r1 = get_region(r0, ' ', ',\n});')
    acqName = GetName(scripts, SCRIPT_START, "name:", ",").lower()
    
    data = json.loads(r1)
    usefulData = data[0]
    zoneName = "Unknown"
    if (acqName == "droppedby"): #Dropped by kill
        dropChance = 0
        for i in data:
            if ('percentOverride' in i):
                dropChance = truncate(i['percentOverride'], 1)
            if ('count' in i):
                if (i['count'] >= 0 and i['outof'] > 0):
                    if (truncate(int(i['count'])/int(i['outof']) * 100, 1) > dropChance):
                        usefulData = i
                        dropChance = truncate(int(usefulData['count'])/int(usefulData['outof']) * 100, 1)
        # Get location
        if ('location' in usefulData):
            zoneName = GetZone(usefulData['location'][0])
        o = Item(itemID, itemName, usefulData['id'], usefulData['name'], "Kill", str(dropChance), zoneName)

    elif (acqName == "soldby"): #Sold by npc
        dropChance = 100
        if ('location' in usefulData):
            zoneName = GetZone(usefulData['location'][0])
        o = Item(itemID, itemName, usefulData['id'], usefulData['name'], "Purchase", str(dropChance), zoneName)

    elif (acqName == "containedin"): #Contained in cache
        dropChance = 0
        for i in data:
            if ('count' in i):
                if (i['count'] >= 0 and i['outof'] > 0):
                    if (truncate(int(i['count'])/int(i['outof']) * 100, 1) > dropChance):
                        usefulData = i
                        dropChance = truncate(int(usefulData['count'])/int(usefulData['outof']) * 100, 1)
        if ('location' in usefulData):
            zoneName = GetZone(usefulData['location'][0])
        o = Item(itemID, itemName, usefulData['id'], usefulData['name'], "Container", str(dropChance), zoneName)
    elif (acqName == "rewardfrom"): #Reward from quest
        if ('category' in usefulData and 'category2' in usefulData):
            zoneName = GetCategory(usefulData['category'], usefulData['category2'])
        o = Item(itemID, itemName, usefulData['id'], GetQuestName(usefulData['id']), "Quest", 0, zoneName)

    elif (acqName == "createdby"): #Crafted
        o = Item(itemID, itemName, usefulData['id'], "", "Recipe", 0, "")
    return o


def writeToFile(items, slotName):
    if (not os.path.exists(path)):
        os.makedirs(path)

    fileContent = ""

    header = """-------------------------------------**     LibEquippable     **-------------------------------------\n-- This file is autogenerated, please do not edit it manually or fuckups might occur.\n-------------------------------------**  All Rights Reserved  **-------------------------------------\n\nlocal LE = LibStub and LibStub(\"LibEquippable-1.0\", true)\nif not LE  then return end\n\nlocal items = {}\nlocal names = {}\n"""

    footer = "\nLE:RegisterDBItems(items)\nLE:RegisterNameDBItems(names)"

    items_scraped = 1
    itemsLua = "\n"
    namesLua = "\n"
    for item in items:
        print ("-----:: Writing item " + str(items_scraped) + "/" + str(len(items)))
        itemsLua += "items[" + item.ID + "] = " + item.toLuaTable() + "\n"
        namesLua += "names[\"" + item.Name.replace('"', '\\"') + "\"] = " + item.ID + "\n"
        items_scraped += 1

    fileContent += header + itemsLua + namesLua + footer

    slotFile = open(path + "/" + slotName + ".lua", "w")
    slotFile.write(fileContent)
    slotFile.close()

def main(argv):
    inputFile = ''
    shouldRewrite = False

    try:
        opts, args = getopt.getopt(argv,"hi:",["ifile=", "rewrite"])
    except getopt.GetoptError:
        print(f'{scriptName} -i <inputFile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(f'{scriptName} -i <inputFile>')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputFile = arg
        elif opt in ("--rewrite"):
            shouldRewrite = True


    allItemsFile = open(inputFile, "r")
    allItems = json.loads(allItemsFile.read())

    for slot in allItems:
        slotName = slot['slot']
        slotItems = slot['items']
        if (os.path.isfile(path + "/" + slotName + ".lua") and not shouldRewrite):
            continue
        
        allSlotData = []
        itemIndex = 1
        for item in slotItems:
            print ("-----:: Scraping item " + str(itemIndex) + "/" + str(len(slotItems)))
            item = GetItem(item)
            allSlotData.append(item)
            print("---:: Scraped item", item.toJson())
            itemIndex += 1
        writeToFile(allSlotData, slotName)


if __name__ == "__main__":
    main(sys.argv[1:])
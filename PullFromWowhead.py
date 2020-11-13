import requests
import json
from bs4 import BeautifulSoup
import sys, getopt

scriptName = "PullFromWowhead.py"

QuestCaregoryUrl = 'https://classic.wowhead.com/quests='
ZoneUrl = 'https://classic.wowhead.com/zone='
URL = 'https://classic.wowhead.com/item='

SCRIPT_START = "var tabsRelated = new Tabs({parent: WH.ge('jkbfksdbl4'), trackable: 'Item'});"
DATA_START = 'data:'

class Item:
    def __init__(self, id, npcID, npcName, kill, quest, questID, recipe, recipeID, dropChance, zone):
        self.ID = id
        self.Obtain = {}
        self.Obtain["NpcID"] = npcID
        self.Obtain["NpcName"] = npcName
        self.Obtain["Kill"] = kill
        self.Obtain["Quest"] = quest
        self.Obtain["QuestID"] = questID
        self.Obtain["Recipe"] = recipe
        self.Obtain["RecipeID"] = recipeID
        self.Obtain["DropChance"] = dropChance
        self.Obtain["Zone"] = zone
    def toJson(self):
        return json.dumps(self, default=lambda o: o.__dict__)

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

def truncate(n, decimals=0):
    multiplier = 10 ** decimals
    return int(n * multiplier) / multiplier


def GetItem(itemID):
    if (itemID == 0):
        return Item(itemID, 0, "", False, False, 0, False, 0, 0, "").toJson()
    data_container = None
    o = Item(itemID, 0, "Unknown acquisition method", False, False, 0, False, 0, 0, "")
    url = URL + str(itemID)
    page = requests.get(url)
    soup = BeautifulSoup(page.content, 'html.parser')

    main = soup.find(id='main-contents')
    scripts = main.findAll('script')
    for child in scripts:
        content = ''.join(child.contents).replace('\n   ', '').strip()
        if content.startswith(SCRIPT_START):
            data_container = content
            if (len(content) < 80):
                print("Scraping Item", itemID, "----", "Invalid Item")
                return Item(itemID, 0, "Invalid Item", False, False, 0, False, 0, 0, "").toJson()
            break
    r0 = get_region(data_container, DATA_START)
    r1 = get_region(r0, ' ', ',\n});')
    acqName = GetName(scripts, SCRIPT_START, "name:", ",").lower()
    print("Scraping item", itemID, "----", acqName)
    
    data = json.loads(r1)
    usefulData = data[0]
    zoneName = "Unknown"
    if (acqName == "droppedby"): #Dropped by kill
        dropChance = 0
        for i in data:
            if ('count' in i):
                if (i['count'] >= 0 and i['outof'] > 0):
                    if (truncate(int(i['count'])/int(i['outof']) * 100, 1) > dropChance):
                        usefulData = i
                        dropChance = truncate(int(usefulData['count'])/int(usefulData['outof']) * 100, 1)
        # Get location
        if ('location' in usefulData):
            zoneName = GetZone(usefulData['location'][0])
        o = Item(itemID, usefulData['id'], usefulData['name'], True, False, 0, False, 0, str(dropChance), zoneName)

    elif (acqName == "soldby"): #Sold by npc
        dropChance = 100
        o = Item(itemID, usefulData['id'], usefulData['name'] + " (Purchase)", True, False, 0, False, 0, str(dropChance), zoneName)

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
        o = Item(itemID, usefulData['id'], usefulData['name'] + " (Container)", True, False, 0, False, 0, str(dropChance), zoneName)

    elif (acqName == "rewardfrom"): #Reward from quest
        if ('category' in usefulData and 'category2' in usefulData):
            zoneName = GetCategory(usefulData['category'], usefulData['category2'])
        o = Item(itemID, 0, "", False, True, usefulData['id'], False, 0, 0, zoneName)

    elif (acqName == "createdby"): #Crafted
        o = Item(itemID, 0, "", False, False, 0, True, usefulData['id'], 0, "")

    elif (acqName == "samemodelas_stc"): #Unknown (Usually pvp)
        o = Item(itemID, 0, "", False, False, 0, False, 0, 0, "")
    return o.toJson()

def main(argv):
    inputFile = ''
    outputFile = ''

    try:
        opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
    except getopt.GetoptError:
        print(f'{scriptName} -i <inputfile> -o <outputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(f'{scriptName} -i <inputfile> -o <outputfile>')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg

    d = None
    with open(inputfile) as file:
        d = json.loads(file.read())

    nd = {}
    currentClass = 0
    amountOfClasses = len(d.items())
    amountOfSpecs = 0
    amountOfSets = 0
    for k, v in d.items():
        currentClass = currentClass + 1
        print("Scraping class", k, f"[{currentClass}/{amountOfClasses}]") # Class
        nd[k] = {}
        currentSpec = 0
        amountOfSpecs = len(v.items())
        for k2, v2 in v.items():
            amountOfSets = len(v2.items())
            currentSpec = currentSpec + 1
            currentSet = 0
            print("Scraping Spec", k2, f"[{currentSpec}/{amountOfSpecs}]") # Phase
            for k3, v3 in v2.items():
                currentSet = currentSet + 1
                ns = k2 + "-" + k3
                print("Scraping Set", ns, f"[{currentSet}/{amountOfSets}]") # Phase
                nd[k][ns] = {}
                nd[k][ns]["Head"] = GetItem(d[k][k2][k3]["Head"]["itemID"])
                nd[k][ns]["Neck"] = GetItem(d[k][k2][k3]["Neck"]["itemID"])
                nd[k][ns]["Shoulder"] = GetItem(d[k][k2][k3]["Shoulder"]["itemID"])
                nd[k][ns]["Back"] = GetItem(d[k][k2][k3]["Cloak"]["itemID"])
                nd[k][ns]["Chest"] = GetItem(d[k][k2][k3]["Chest"]["itemID"])
                nd[k][ns]["Shirt"] = GetItem(0)
                nd[k][ns]["Tabard"] = GetItem(0)
                nd[k][ns]["Wrists"] = GetItem(d[k][k2][k3]["Wrist"]["itemID"])
                nd[k][ns]["Hands"] = GetItem(d[k][k2][k3]["Gloves"]["itemID"])
                nd[k][ns]["Waist"] = GetItem(d[k][k2][k3]["Waist"]["itemID"])
                nd[k][ns]["Legs"] = GetItem(d[k][k2][k3]["Legs"]["itemID"])
                nd[k][ns]["Feet"] = GetItem(d[k][k2][k3]["Boots"]["itemID"])
                nd[k][ns]["Finger"] = GetItem(d[k][k2][k3]["Ring1"]["itemID"])
                nd[k][ns]["RFinger"] = GetItem(d[k][k2][k3]["Ring2"]["itemID"])
                nd[k][ns]["Trinket"] = GetItem(d[k][k2][k3]["Trinket1"]["itemID"])
                nd[k][ns]["RTrinket"] = GetItem(d[k][k2][k3]["Trinket2"]["itemID"])
                nd[k][ns]["MainHand"] = GetItem(d[k][k2][k3]["MainHand"]["itemID"])
                nd[k][ns]["SecondaryHand"] = GetItem(d[k][k2][k3]["OffHand"]["itemID"])
                nd[k][ns]["Relic"] = GetItem(d[k][k2][k3]["Ranged"]["itemID"])
    print("---Done with scrape---")

    newFile = open(outputfile, "w")
    newFile.write(json.dumps(nd).replace('"{', '{').replace('}"', '}').replace('\\', ''))
    newFile.close()

if __name__ == "__main__":
    main(sys.argv[1:])
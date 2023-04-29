import requests
import json
import sys, getopt
from bs4 import BeautifulSoup

scriptName = "GetAllItemsFromWowhead.py"
URL = 'https://wotlk.wowhead.com/items/min-req-level:{minlevel}/max-req-level:{maxlevel}/slot:{slot}'
SCRIPT_START = "//<![CDATA["
DATA_START = "WH.Gatherer.addData(3, 8, "
DATA_END = ");"


SLOTS = [    
    { "id": 24, "name": "Ammo"},
    { "id": 16, "name": "Back"},
    { "id": 18, "name": "Bag"},
    { "id": 5, "name": "Chest"},
    { "id": 8, "name": "Feet"},
    { "id": 11, "name": "Finger"},
    { "id": 10, "name": "Hands"},
    { "id": 1, "name": "Head"},
    { "id": 23, "name": "Held In Off-hand"},
    { "id": 7, "name": "Legs"},
    { "id": 21, "name": "Main Hand"},
    { "id": 2, "name": "Neck"},
    { "id": 22, "name": "Off Hand"},
    { "id": 13, "name": "One-Hand"},
    { "id": 15, "name": "Ranged"},
    { "id": 28, "name": "Relic"},
    { "id": 14, "name": "Shield"},
    { "id": 4, "name": "Shirt"},
    { "id": 3, "name": "Shoulder"},
    { "id": 19, "name": "Tabard"},
    { "id": 25, "name": "Thrown"},
    { "id": 12, "name": "Trinket"},
    { "id": 17, "name": "Two-Hand"},
    { "id": 6, "name": "Waist"},
    { "id": 9, "name": "Wrist"}
]

LEVEL_RANGES = [
    {
        'min_level': 0,
        'max_level': 0
    },
    # {
    #     'min_level': 26,
    #     'max_level': 50
    # },
    # {
    #     'min_level': 51,
    #     'max_level': 75
    # },
    # {
    #     'min_level': 76,
    #     'max_level': 100
    # },
]

def scrape_item_page(pageUrl):
    items = []
    page = requests.get(pageUrl)
    soup = BeautifulSoup(page.content, 'html.parser')

    main = soup.find(id='main-contents')
    scripts = main.findAll('script')
    for child in scripts:
        content = ''.join(child.contents).replace('\n   ', '').strip()
        if content.startswith(SCRIPT_START):
            jsonData = content.split(DATA_START)[1].split(DATA_END)[0]
            data = json.loads(jsonData)
            items = list(data.keys())

    return items


def scrape_all_items():
    items = []
    currentSlot = 0
    for slot in SLOTS:
        currentSlot += 1
        print("------:: Getting items from slot", str(currentSlot)+"/"+str(len(SLOTS))+":", slot['id'], slot['name'])
        slotItems = []
        for levelRange in LEVEL_RANGES:
            print("---:: Getting items from level range", levelRange['min_level'], "-", levelRange['max_level'])
            tempUrl = URL.replace("{minlevel}", str(levelRange['min_level'])).replace("{maxlevel}", str(levelRange['max_level'])).replace("{slot}", str(slot['id']))
            levelRangeItems = scrape_item_page(tempUrl)
            print("-:: Found", len(levelRangeItems), "items")
            slotItems.extend(levelRangeItems)
        print("------:: Found", len(slotItems), "items in total for current slot")
        items.append({
            "slot": slot['name'],
            "items": slotItems
        })
    return items

def main(argv):
    outputFile = ''

    try:
        opts, args = getopt.getopt(argv,"ho:",["ofile="])
    except getopt.GetoptError:
        print(f'{scriptName} -o <outputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(f'{scriptName} -o <outputfile>')
            sys.exit()
        elif opt in ("-o", "--ofile"):
            outputFile = arg


    allItems = scrape_all_items()

    if (outputFile == ''):
        print(allItems)
        return
    else:
        newFile = open(outputFile, "w")
        newFile.write(json.dumps(allItems))
        newFile.close()


if __name__ == "__main__":
    main(sys.argv[1:])
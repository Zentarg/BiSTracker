import requests
import json
import sys, getopt
import re
import string
from bs4 import BeautifulSoup


from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.edge.service import Service as EdgeService
from webdriver_manager.microsoft import EdgeChromiumDriverManager

driver = webdriver.Edge(service=EdgeService(EdgeChromiumDriverManager().install()))

SET_BASE_URL = "https://www.wowhead.com/wotlk/guide/classes/{class}/{spec}/{role}-bis-gear-"

SET_URLS = {
    "Pre-Raid p2": "pre-raid-pve-p2",
    "PvE p2": "pve-phase-2",
    "PvP s6": "pvp-arena-season-6"
}
PLANNER_URL = "https://www.wowhead.com/wotlk/gear-planner/{setLink}"

GEAR_PLANNER_SET_START = "[center][h4]"
GEAR_PLANNER_SET_END = "[\\\\/h4]"
GER_PLANNER_SET_ALTERNATIVE_END = "[\\/h4]"
GEAR_PLANNER_SET_DIVIDER = "\\n"

GEAR_PLANNER_LINK_START = "[gear-planner="
GEAR_PLANNER_LINK_END = "]"
GEAR_PLANNER_REGEX = re.compile('(gear-planner=).*?(?=])')

ACTUAL_LINK = "BgFQFgBVEhUzMAMDIBAgE_MFBQUAACPwBfAfMDAxczlkMTFzOW0yMXh2NjMxdHM4NDFzeGQ1MXM4Z4FAmskA6jMAoaQgnGICAJ7ngyCaywDzsACcYoUAmeYAuxyGQJ7xANXQAJyZIJxIh0CaygDspQCceyCcYogAnycA1uiJAJ8eAPMwiiCayAD5GgCcYgsAnw4MAJjlDUCsHwCcYiCcmQ4AkWSPIKvUALo4AJyYkACZ-QDyzhIAnwo"

SETS_TO_GET = [
    {
        "class": "death-knight",
        "spec": "blood",
        "role": "tank"    
    },
    {
        "class": "death-knight",
        "spec": "frost",
        "role": "dps"    
    },
    {
        "class": "death-knight",
        "spec": "unholy",
        "role": "tank"    
    },
    {
        "class": "druid",
        "spec": "balance",
        "role": "dps"    
    },
    {
        "class": "druid",
        "spec": "feral",
        "role": "dps"
    },
    {
        "class": "druid",
        "spec": "feral",
        "role": "tank"
    },
    {
        "class": "druid",
        "spec": "restoration",
        "role": "healer"
    },
    {
        "class": "hunter",
        "spec": "beast-mastery",
        "role": "dps"
    },
    {
        "class": "hunter",
        "spec": "marksmanship",
        "role": "dps"
    },
    {
        "class": "hunter",
        "spec": "survival",
        "role": "dps"
    },
    {
        "class": "mage",
        "spec": "arcane",
        "role": "dps"
    },
    {
        "class": "mage",
        "spec": "fire",
        "role": "dps"
    },
    {
        "class": "mage",
        "spec": "frost",
        "role": "dps"
    },
    {
        "class": "paladin",
        "spec": "holy",
        "role": "healer"
    },
    {
        "class": "paladin",
        "spec": "protection",
        "role": "tank"
    },
    {
        "class": "paladin",
        "spec": "retribution",
        "role": "dps"
    },
    {
        "class": "priest",
        "spec": "discipline",
        "role": "healer"
    },
    {
        "class": "priest",
        "spec": "holy",
        "role": "healer"
    },
    {
        "class": "priest",
        "spec": "shadow",
        "role": "dps"
    },
    {
        "class": "rogue",
        "spec": "assassination",
        "role": "dps"
    },
    {
        "class": "rogue",
        "spec": "combat",
        "role": "dps"
    },
    {
        "class": "rogue",
        "spec": "subtlety",
        "role": "dps"
    },
    {
        "class": "shaman",
        "spec": "elemental",
        "role": "dps"
    },
    {
        "class": "shaman",
        "spec": "enhancement",
        "role": "dps"
    },
    {
        "class": "shaman",
        "spec": "restoration",
        "role": "healer"
    },
    {
        "class": "warlock",
        "spec": "affliction",
        "role": "dps"
    },
    {
        "class": "warlock",
        "spec": "demonology",
        "role": "dps"
    },
    {
        "class": "warlock",
        "spec": "destruction",
        "role": "dps"
    },
    {
        "class": "warrior",
        "spec": "arms",
        "role": "dps"
    },
    {
        "class": "warrior",
        "spec": "fury",
        "role": "dps"
    },
    {
        "class": "warrior",
        "spec": "protection",
        "role": "tank"
    },
]

def find_gear_planner_links(pageUrl):
    content = requests.get(pageUrl).content
    print(pageUrl)
    links = []

    if (GEAR_PLANNER_SET_START in str(content)):
        for i, string in enumerate(str(content).split(GEAR_PLANNER_SET_START)):
            if not i: continue
            setEnd = GEAR_PLANNER_SET_END
            if (not setEnd in string):
                setEnd = GER_PLANNER_SET_ALTERNATIVE_END
                if (not setEnd in string):
                    continue
            setName = string.split(setEnd)[0]
            if (GEAR_PLANNER_SET_DIVIDER in setName):
                setName = setName.split(GEAR_PLANNER_SET_DIVIDER)[1]
            if ("Alliance" in setName):
                setName = "Alliance"
            elif ("Horde" in setName):
                setName = "Horde"
            link = string.split(GEAR_PLANNER_LINK_START)[1].split(GEAR_PLANNER_LINK_END)[0]
            if (len(link) < 40): continue
            formattedLink = link.replace("\\", "")
            links.append({"name": setName, "link": formattedLink})
    else:
        for i, string in enumerate(str(content).split(GEAR_PLANNER_LINK_START)):
            if not i: continue
            link = string.split(GEAR_PLANNER_LINK_END)[0]

            if (len(link) < 40): continue
            formattedLink = link.replace("\\", "")
            links.append({"name": '', "link": formattedLink})

    return links

def get_sets_for_spec(classString, spec, role):
    sets = {}
    for key in SET_URLS:
        url = SET_URLS[key]
        setUrl = SET_BASE_URL + url
        setUrl = setUrl.replace("{class}", classString).replace("{spec}", spec).replace("{role}", role)
        for setData in find_gear_planner_links(setUrl):
            name = setData['name']
            gearPlannerUrl = PLANNER_URL.replace("{setLink}", setData['link'])

            driver.get(gearPlannerUrl)
            rows = driver.find_elements(By.CLASS_NAME, "listview-row")

            set = {
                "Head": 0,
                "Neck": 0,
                "Shoulder": 0,
                "Back": 0,
                "Chest": 0,
                "Shirt": 0,
                "Tabard": 0,
                "Wrists": 0,
                "Hands": 0,
                "Waist": 0,
                "Legs": 0,
                "Feet": 0,
                "Finger": 0,
                "RFinger": 0,
                "Trinket": 0,
                "RTrinket": 0,
                "MainHand": 0,
                "SecondaryHand": 0,
                "Relic": 0
            }
            
            for row in rows:
                a = row.find_element(By.TAG_NAME, "a").get_attribute("href")
                slotName = row.find_element(By.XPATH, "td[5]").text
                id = a.split("=")[1].split("/")[0]
                
                if (slotName == "Wrist"):
                    set["Wrists"] = id
                elif (slotName == "Finger" and set["Finger"] != 0):
                    set["RFinger"] = id
                elif (slotName == "Trinket" and set["Trinket"] != 0):
                    set["RTrinket"] = id
                elif (slotName == "Two-Hand"):
                    set["MainHand"] = id
                elif (slotName == "One-Hand"):
                    if (set["MainHand"] == 0):
                        set["MainHand"] = id
                    else:
                        set["SecondaryHand"] = id
                elif (slotName == "Main Hand"):
                    set["MainHand"] = id
                elif (slotName == "Held In Off-hand" or slotName == "Off Hand" or slotName == "Shield"):
                    set["SecondaryHand"] = id
                elif (slotName == "Ranged" or slotName == "Thrown"):
                    set["Relic"] = id
                else:
                    set[slotName] = id
            if (name == ""):
                sets[string.capwords(spec) + " " + string.capwords(role) + " - " + key] = set
            else:
                sets[string.capwords(spec) + " " + string.capwords(role) + " " + name + " - " + key] = set

    return sets
        
def get_all_sets():
    allSets = {}
    for setToGet in SETS_TO_GET:
        if not setToGet['class'] in allSets:
            allSets[setToGet['class']] = {}
        sets = get_sets_for_spec(setToGet['class'], setToGet['spec'], setToGet['role'])
        for set in sets:
            allSets[setToGet['class']][set] = sets[set]
            

    print(allSets)

    luaString = "BiSData = {"
    for classSets in allSets:
        className = classSets.replace("-", "")
        classString = string.capwords(className) + " = {"

        for set in allSets[classSets]:
            classString += '["' + set + '"] = {'
            
            for slot in allSets[classSets][set]:
                classString += slot + " = " + str(allSets[classSets][set][slot]) + ","

            classString += "},"

        classString += "},"
        luaString += classString
    luaString += "}"
    return luaString

        


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

    allSetsLua = get_all_sets()


    if (outputFile == ''):
        print(allSetsLua)
        return
    else:
        newFile = open(outputFile, "w")
        newFile.write(allSetsLua)
        newFile.close()


if __name__ == "__main__":
    main(sys.argv[1:])
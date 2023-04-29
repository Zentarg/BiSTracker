import requests
import json
import sys, getopt
import re
import string

SLOT_NAME_MAP = {
    "head_item": "Head",
    "neck_item": "Neck",
    "shoulder_item": "Shoulder",
    "back_item": "Back",
    "chest_item": "Chest",
    "wrist_item": "Wrists",
    "hand_item": "Hands",
    "waist_item": "Waist",
    "leg_item": "Legs",
    "foot_item": "Feet",
    "finger1_item": "Finger",
    "finger2_item": "RFinger",
    "trinket1_item": "Trinket",
    "trinket2_item": "RTrinket",
    "mainhand_item": "MainHand",
    "offhand_item": "SecondaryHand",
    "range_item": "Relic"
}

def get_set_name(className, name, race, faction, stage):
    name = str(name).lower().replace(className, "")


    if ("(" in name):
        name = ', '.join(str(name).replace(")", "").replace(" ", "").split("(")[1].split(","))

    if (faction):
        if (len(name) > 2):
            name += " - " + faction
        else:
            name = faction

    if (race):
        if (len(name) > 2):
            name += " - " + str(race).replace("-" + className, "")
        else:
            name = str(race).replace("-" + className, "")
    
    if (len(name) > 2):
        if (stage == 1):
            return name + " - p1 pre-raid"
        elif(stage == 2):
            return name + " - p2 pre-raid "
        else:
            return name + " - p" + str(stage)
    return "p" + str(stage)

def format_set(set):
    formatted_set = {
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
    
    for item, value in set.items():
        if (not "_item" in item):
            continue
        slot = SLOT_NAME_MAP[item]
        formatted_set[slot] = value
    return formatted_set

def format_all_sets(sets):
    all_sets = {

    }

    for set in sets:
        className = set["wowclass"]
        setName = get_set_name(className, set["name"], set["race"], set["faction"], set["stage"])
        if (not className in all_sets):
            all_sets[className] = {}
        all_sets[className][setName] = format_set(set)
    return all_sets

def to_lua(sets):
    luaString = "BiSData = {"
    for classSets in sets:
        classString = string.capwords(classSets) + " = {"

        for set in sets[classSets]:
            classString += '["' + set + '"] = {'
            
            for slot in sets[classSets][set]:
                classString += slot + " = " + str(sets[classSets][set][slot]) + ","

            classString += "},"

        classString += "},"
        luaString += classString
    luaString += "}"
    return luaString

def main(argv):
    outputFile = ''
    inputFile = ''

    try:
        opts, args = getopt.getopt(argv,"ho:i:",["ofile=", "ifile="])
    except getopt.GetoptError:
        print(f'{scriptName} -o <outputfile> -i <inputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(f'{scriptName} -o <outputfile> -i <inputfile>')
            sys.exit()
        elif opt in ("-o", "--ofile"):
            outputFile = arg
        elif opt in ("-i", "--ifile"):
            inputFile = arg
            
    f = open(inputFile, "r")
    sets = json.load(f)
    allSets = format_all_sets(sets)
    allSetsLua = to_lua(allSets)

    if (outputFile == ''):
        print(allSetsLua)
        return
    else:
        newFile = open(outputFile, "w")
        newFile.write(allSetsLua)
        newFile.close()


if __name__ == "__main__":
    main(sys.argv[1:])
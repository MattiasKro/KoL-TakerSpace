
Record Creation {
	int seq;
    int itemid;
    string name;
	string description;
	string icon;
	boolean found;
	int [string] resources;
};

string [int] __TAKER_required = {"spice", "rum", "anchor", "mast", "silk", "gold"};
string [string] __TAKER_supplies  = {
    "spice": "stolen spices", 
    "rum": "robbed rums", 
    "anchor": "absconded-with anchor", 
    "mast": "misappropriated mainmasts", 
    "silk": "snatched silk", 
    "gold": "gaffled gold"
};

string getSupply(string [int] pageData, string key) {
    string result = "";
    foreach ix, row in pageData {
        if (contains_text(row, "Current Supplies:")) {
            matcher resource_match = create_matcher("<br>(\\d+) " + key +"<br>", row);
            if ( resource_match.find() ) {
                result = group(resource_match, 1);
            } else {
                print("Could not parse " + key, "red");
            }
        }
    }
    return result;
}

int [string] getSupplies(string pageData) {
    int [string] result;
    string [int] pageRows = split_string(pageData, "\n");

    foreach key, val in __TAKER_supplies {
        result[key] = to_int(getSupply(pageRows, val));
//        print(to_string(result[key]) + " " + val);
    }
    return result;
}

Creation[int] getCreations() {
    Creation[int] result;
    string [int, int] creationsData = {
        {"1", "deft pirate hook", "Melting offhand. MUS +20, WDmg +10. Snags stuff.", "ts_hook", "0 0 1 1 0 1"},
        {"2", "iron tricorn hat", "Melting hat. HP +40, DR +10. 11x 3-turn stun.", "ts_tricorn", "0 0 2 1 0 0"},
        {"3", "jolly roger flag", "Melting accessory. +25% meat, Scares rich monsters.", "ts_roger", "0 0 1 1 0 1"},
        {"4", "sleeping profane parrot", "Familiar hatchling.", "ts_parrot1", "15 3 0 0 2 1"},
        {"5", "pirrrate's currrse", "Usable. Chat effect.", "ts_curse", "2 2 0 0 0 0"},
        {"6", "tankard of spiced rum", "4/1 Booze", "tankard", "1 2 0 0 0 0"},
        {"7", "tankard of spiced Goldschlepper", "7/1 booze", "tankard", "0 2 0 0 0 1"},
        {"8", "packaged luxury garment", "Governor's Daughter's Fancy Finery outfit pirce.", "ts_garment", "0 0 0 0 3 2"},
        {"9", "harpoon", "Combat item. Deals physical damage.", "ts_harpoon", "0 0 0 2 0 0"},
        {"10", "chili powder cutlass", "1-Handed Sword. +20 <font color='red'>Hot damage</font>", "ts_cutlass", "5 0 1 0 0 0"},
        {"11", "cursed Aztec tamale", "5/1 food. 20 turns of +10 <font color='grey'>Spooky damage</font>", "ts_tamale", "2 0 0 0 0 0"},
        {"12", "jolly roger tattoo kit", "Tattoo!", "ts_tatkit", "0 6 1 1 0 6"},
        {"13", "golden pet rock", "Familiar hatchling.", "ts_goldrock", "0 0 0 0 0 7"},
        {"14", "groggles", "+50% Booze drop accessory.", "ts_goggles", "0 6 0 0 0 0"},
        {"15", "pirate dinghy", "Access to the Island. One free +1000HP/+1000MP heal per day.", "ts_dinghy", "0 0 1 1 1 0"},
        {"16", "anchor bomb", "Combat item. 30 turn banish.", "ts_bomb", "0 1 3 1 0 1"},
        {"17", "silky pirate drawers", "Pants. +50% init, -5% combat", "ts_pants", "0 0 0 0 2 0"},
        {"18", "spices", "Good old spices. Nothing beats spices.", "spice", "1 0 0 0 0 0"}
    };

    foreach row in creationsData {
        Creation c = new Creation();
        c.seq = to_int(creationsData[row][0]);
        c.name = creationsData[row][1];
        c.description = creationsData[row][2];
        c.icon = creationsData[row][3];
    
        string [int] rs = split_string(creationsData[row][4], " ");
        foreach r in rs {
            c.resources[__TAKER_required[r]] = to_int(rs[r]);
        }
        result[c.seq] = c;
    }

    return result;
}

string createCreationBox(Creation recipe, int canCreate) {
    string border = 'border: 2px ';
    if (recipe.found && canCreate > 0) {
        border += 'solid #000';
    } else if (recipe.found && canCreate < 0) {
        border += 'dashed #b44';
    } else if (!recipe.found && canCreate > 0) {
        border += 'solid #4b4';
    } else if (!recipe.found && canCreate < 0) {
        border += 'dashed #b44';
    }
    string altText = "";
    if (canCreate > 0) {
        altText = "Can create " + to_string(canCreate);
    } else { // <font color='red'>Hot damage</font>
        altText = "Need <font color='red'>" + to_string(-1*canCreate) + "</font> more days of supplies";
    }

    string disabled = "";
    if (canCreate < 0) {
        disabled = " disabled ";
    }

    string result = '<form method="post" action="choice.php">\n';
    result += '     <input type="hidden" name="pwd" value="' + my_hash() + '">\n';
    result += '     <input type="hidden" name="option" value="1">\n';
    result += '     <input type="hidden" name="whichchoice" value="1537">\n';
    foreach ix, part in __TAKER_required {
        result += '     <input type="hidden" name="' + part + '" value="' + recipe.resources[part] + '">\n';
    }
    result += '     <div style="display: flex">\n';
    result += '     <button class="button" type="submit"' + disabled + ' title="' + altText + '" style="display: flex; ' + border + '">\n';
    result += '        <div style="margin-right: 1em">\n';
    result += '        ' + recipe.name + '<br>\n';
    result += '        ' + recipe.description + '<br>\n';
    result += '        ' + altText + '<br>\n';
    boolean first = true;
    foreach ix, part in __TAKER_required {
        if (first) {
            first = false;
        } else {
            result += ', \n';
        }
        result += '        ' + recipe.resources[part] + ' ' + part;
    }
    result += '\n';
    result += '        </div>\n';
    result += '        <img src="/images/itemimages/' + recipe.icon + '.gif" height="30" align="absmiddle">\n';
    result += '     </button>\n';
//    result += '     <img src="/images/itemimages/magnify.gif" align="absmiddle" onclick="descitem('322564205')" height="30" width="30">\n';
    result += '     </div>\n';
    result += '</form>\n';

    return result;
}

int checkSupplies(Creation recipe, int [string] resources) {
    int [String] dailyAllowance = {
        "spice": 3, 
        "rum": 3, 
        "anchor": 3, 
        "mast": 3, 
        "silk": 1, 
        "gold": 1
    };
    int result = 0;
    int minRes = -100;
    int maxRes = 100;
    boolean canMake = true;
    foreach resource, amount in resources {
        if (recipe.resources[resource] > 0) {
            if (amount >= recipe.resources[resource]) {
                maxRes = min(floor(amount/recipe.resources[resource]), maxRes);
            } else {
                int deficiency = recipe.resources[resource]-amount;
                float daysToFill = deficiency / dailyAllowance[resource];
                int wholeDays = ceil(deficiency);
                minRes = max(-1*wholeDays, minRes);
                canMake = false;
            }
        }
    }
    if (canMake) {
        result = maxRes;
    } else {
        result = minRes;
    }
//    print(recipe.name + ": " + to_string(result));
    return result; 
}

string renderPage(string oldPage, Creation[int] recipes) {
    string newPage = "";
    string divider = "You swagger into your workshed and survey your TakerSpace.";
    string campLink = '<a href="campground.php">Back to Campground</a><br>&nbsp;</td></tr><tr><td><center>';

    string [int] oldParts = split_string(oldPage, divider);
    int [string] resources = getSupplies(oldPage);

    foreach ix, recipe in recipes {
        if (contains_text(oldPage, recipe.name)) {
            recipes[ix].found = true;
        } else {
            recipes[ix].found = false;
        }
        int availability = checkSupplies(recipe, resources);
        newPage += createCreationBox(recipes[ix], availability);
    }
    return oldParts[0] + divider + "<br><br>" + newPage + campLink + oldParts[1];
}

string handleTakerSpace(string origPage) {
    Creation[int] creations = getCreations();
    String newPage = renderPage(origPage, creations);
    return newPage;
}


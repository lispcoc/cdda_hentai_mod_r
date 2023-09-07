const fs = require('fs');

const path = "json/monsters/monsters.json"
const base = fs.readFileSync(path)
var json = JSON.parse(base)
for(var j of json) {
    if(j["special_attacks"]) {
        delete j["special_attacks"]
    }
}
fs.writeFileSync(path, JSON.stringify(json))

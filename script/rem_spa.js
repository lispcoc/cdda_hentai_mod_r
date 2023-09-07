const fs = require('fs')

const path = process.argv[2]
console.log(path)
const base = fs.readFileSync(path)
var json = JSON.parse(base)
for(var j of json) {
    if(j["special_attacks"]) {
        delete j["special_attacks"]
    }
}
fs.writeFileSync(path, JSON.stringify(json))

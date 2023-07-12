import time
start_time = time.time()

import json
import ijson

i=0
with open("dblp.v12_trunc.json", "a") as data:
    data.write("[")
    with open("dblp.v12.json", "rb") as f:
        for record in ijson.items(f, "item", use_float=True):
                if record["year"] <= 2010:
                    record.pop("indexed_abstract", "no abstarct")
                    record.pop("fos", "no abstarct")

                    data.write(json.dumps(record, indent=2))
                    data.write(",\n")
    data.write("]")
    data.close()

print("--- %s seconds ---" % (time.time() - start_time))
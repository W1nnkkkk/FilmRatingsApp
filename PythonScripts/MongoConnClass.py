from pymongo import MongoClient


class MongoEntity:
    def __init__(self):
        try:
            self.conn = MongoClient("YOUR HOST", port=27017) #standart port
            self.data_base = self.conn["moviebox"]
            self.collection = self.data_base["movies"]
        except Exception as err:
            print(f"Error in mongodb connection {err}")

    def add_to_collection(self, document):
        try:
            self.collection.insert_one(document=document)
        except Exception as err:
            print(f"Error in mongodb insert {err}")
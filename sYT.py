import urllib.parse
import requests
import json
import argparse
import os


class searchYouTube:
    """Youtube Crawler without API"""

    def __init__(self, *args):
        self.search_term = args[0]
        self.max_results = args[1]
        self.BASE_URL = "https://youtube.com"
        self.videos = self.sendRequest()

    def sendRequest(self):
        encoded_search = urllib.parse.quote_plus(self.search_term)
        url = f"{self.BASE_URL}/results?search_query={encoded_search}"
        response = requests.get(url).text
        while "ytInitialData" not in response:
            response = requests.get(url).text
        results = self.parseHTML(response)
        if self.max_results is not None and len(results) > self.max_results:
            return results[: self.max_results]
        return results

    def parseHTML(self, response):

        # Get the string only having data of all the videos
        st = response.index("ytInitialData") + len("ytInitialData") + 3
        en = response.index("};", st) + 1
        json_str = response[st:en]

        # Convert the the above sliced string into json and select the contents part containing all the required data
        response = json.loads(json_str)
        videos = response["contents"]["twoColumnSearchResultsRenderer"][
            "primaryContents"
        ]["sectionListRenderer"]["contents"][0]["itemSectionRenderer"]["contents"]

        #  Master list containing all the info about the videos
        final = []
        for video in videos:
            # Current video master dictionary
            output = {}
            if "videoRenderer" in video.keys():
                # Get current video
                # curr_video = video["videoRenderer"]
                curr_video = video.get("videoRenderer", {})

                # Get Thumbnails from current video [Future Release]
                # thumbnails = curr_video["thumbnail"]["thumbnails"]
                # tmp = []
                # for t in thumbnails:
                #     tmp.append(t["url"])
                # output["Thumbnails"] = tmp
                # del tmp

                # Get Title from current video
                # title = curr_video["title"]["runs"][0]["text"]
                title = (
                    curr_video.get("title", "NA").get("runs", "NA")[0].get("text", "NA")
                )
                output["Title"] = title

                # Get channel name from current video
                # channel_name = curr_video["longBylineText"]["runs"][0]["text"]
                channel_name = (
                    curr_video.get("longBylineText", "NA")
                    .get("runs", "NA")[0]
                    .get("text", "NA")
                )
                output["Channel"] = channel_name

                # Get duration from current video
                # duration = curr_video["lengthText"]["simpleText"]
                duration = curr_video.get("lengthText", "NA").get("simpleText", "NA")
                output["Duration"] = duration

                # Get total views from current video
                # views = curr_video["shortViewCountText"]["simpleText"]
                # views = curr_video.get("shortViewCountText", "NA").get(
                #     "simpleText", "NA"
                # )
                # output["Views"] = views

                # Get upload date from current video
                # upload_date = curr_video["publishedTimeText"]["simpleText"]
                upload_date = curr_video.get("publishedTimeText", "NA").get(
                    "simpleText", "NA"
                )
                output["Uploaded"] = upload_date

                # Get url from current video
                # url_ = curr_video["navigationEndpoint"]["commandMetadata"][
                #     "webCommandMetadata"
                # ]["url"]
                url_ = (
                    curr_video.get("navigationEndpoint", "NA")
                    .get("commandMetadata", "NA")
                    .get("webCommandMetadata", "NA")
                    .get("url", "NA")
                )
                # output["Link"] = "https://www.youtube.com" + url_
                output["Link"] = "https://www.youtube.com" + url_

                # Append current video to the final master list
                final.append(output)
        return final

    def get_json(self):
        return json.dumps({"videos": self.videos})

    def get_dict(self):
        return self.videos


# Command line args
parser = argparse.ArgumentParser()

# Add query to search
parser.add_argument("-q", type=str, default="neovim", help="Query to search.")
args = parser.parse_args()

# Call the class
obj = searchYouTube(args.q, 20)

# Get json and store it in the user folder
jsonString = json.dumps(obj.get_dict(), indent=4)
path = "~/data.json"
jsonFile = open(os.path.expanduser(path), "w")
jsonFile.write(jsonString)
jsonFile.close()

import requests
import threading
import json
import argparse
import os
import urllib.request
import time
from numerize import numerize


class searchYouTube:
    """Youtube Crawler without API"""

    def __init__(self, *args):
        self.search_term = args[0]
        self.max_results = args[1]
        self.algo = args[2]

        self.BASE_URL = "https://youtube.com"

        if self.algo == "v2":
            self.videos = self.parseV2()
        else:
            self.videos = self.sendRequest()

    def human_time_duration(self, seconds):
        TIME_DURATION_UNITS = (
            ("week", 60 * 60 * 24 * 7),
            ("day", 60 * 60 * 24),
            ("hour", 60 * 60),
            ("min", 60),
            ("sec", 1),
        )

        if seconds == 0:
            return "inf"
        parts = []
        for unit, div in TIME_DURATION_UNITS:
            amount, seconds = divmod(int(seconds), div)
            if amount > 0:
                parts.append("{} {}{}".format(amount, unit, "" if amount == 1 else "s"))
        return ", ".join(parts)

    def sendRequest(self):
        encoded_search = self.search_term.split(" ")
        encoded_search = "+".join(encoded_search)
        url = f"{self.BASE_URL}/results?search_query={encoded_search}"
        response = requests.get(url).text
        while "ytInitialData" not in response:
            response = requests.get(url).text
        results = self.parseV1(response)
        if self.max_results is not None and len(results) > self.max_results:
            return results[: self.max_results]
        return results

    def download(self, url, metadata, final=None, idx=None):
        thumbDir = os.path.expanduser("~/.cache/thumbs")
        file_name = str(time.time())
        full_path = thumbDir + "/" + file_name + ".png"

        if idx and final:
            final[idx]["Location"] = full_path

        urllib.request.urlretrieve(url, full_path)
        metadata += f"Thumbnail : {full_path}\n"

        with open(f"{full_path}", "a+") as f:
            f.write(metadata)

        if idx >= 0 and final:
            final[idx]["Location"] = full_path

    def startThumbnailJob(self, thumburl, meta, final):
        threads = []

        for i in range(len(thumburl)):
            thread = threading.Thread(
                target=self.download, args=(thumburl[i], meta[i], final, i)
            )
            thread.start()
            threads.append(thread)

        for thread in threads:
            thread.join()

    def parseV2(self):
        base_url = "https://invidious.fdn.fr"
        searchEndpoint = f"{base_url}/api/v1/search?q={self.search_term}"
        response = requests.get(searchEndpoint)
        videos = json.loads(response.content)
        final = []
        c = 0

        # Thumnail Jobs
        thumburl = []
        meta = []

        for video in videos:
            if c <= self.max_results:
                if video["type"] == "video":
                    vID = video["videoId"]
                    videoId = f"https://www.youtube.com/watch?v={vID}"

                    tmp = {}
                    metadata = ""

                    tmp["Title"] = video["title"]
                    metadata += f"Title : {tmp['Title']}\n"

                    tmp["Channel"] = video["author"]
                    metadata += f"Channel Name : {tmp['Channel']}\n"

                    tmp["Duration"] = self.human_time_duration(video["lengthSeconds"])
                    metadata += f"Duration : {tmp['Duration']}\n"

                    tmp["Views"] = numerize.numerize(video["viewCount"])
                    metadata += f"Views : {tmp['Views']}\n"

                    tmp["Uploaded"] = time.strftime(
                        "%a, %d %b %Y %H:%M:%S", time.localtime(video["published"])
                    )
                    metadata += f"Upload Date : {tmp['Uploaded']}\n"

                    tmp["Link"] = videoId
                    metadata += f"Link : {tmp['Link']}\n"

                    tmp["Thumbnail"] = video["videoThumbnails"][4]["url"]
                    thumburl.append(tmp["Thumbnail"])
                    meta.append("\n\n" + metadata)
                    tmp["Location"] = ""

                    final.append(tmp)
                    c += 1

        self.startThumbnailJob(thumburl, meta, final)

        return final

    def parseV1(self, response):
        # Get the string only having data of all the videos
        st = response.index("ytInitialData") + len("ytInitialData") + 3
        en = response.index("};", st) + 1
        json_str = response[st:en]
        c = 0

        # Convert the the above sliced string into json
        response = json.loads(json_str)
        videos = response["contents"]["twoColumnSearchResultsRenderer"][
            "primaryContents"
        ]["sectionListRenderer"]["contents"][0]["itemSectionRenderer"]["contents"]

        #  Master list containing all the info about the videos
        final = []

        # Thumnail Jobs
        thumburl = []
        meta = []

        metadata = ""
        for video in videos:
            # Current video master dictionary
            output = {}
            if c <= self.max_results:
                if "videoRenderer" in video.keys():
                    # Get current video
                    curr_video = video.get("videoRenderer", {})

                    # Get Title from current video
                    title = (
                        curr_video.get("title", {})
                        .get("runs", [[{}]])[0]
                        .get("text", "NA")
                    )
                    output["Title"] = title
                    metadata += f"Title : {title}\n"

                    # Get channel name from current video
                    channel_name = (
                        curr_video.get("longBylineText", {})
                        .get("runs", [[{}]])[0]
                        .get("text", "NA")
                    )
                    output["Channel"] = channel_name
                    metadata += f"Channel Name : {channel_name}\n"

                    # Get duration from current video
                    duration = curr_video.get("lengthText", {}).get("simpleText", 0)
                    output["Duration"] = duration
                    metadata += f"Duration : {duration}\n"

                    # Get total views from current video
                    views = curr_video.get("shortViewCountText", {}).get(
                        "simpleText", "NA"
                    )
                    output["Views"] = views
                    metadata += f"Views : {views}\n"

                    # Get upload date from current video
                    upload_date = curr_video.get("publishedTimeText", {}).get(
                        "simpleText", "NA"
                    )
                    output["Uploaded"] = upload_date
                    metadata += f"Upload Date : {upload_date}\n"

                    # Get url from current video
                    url_ = (
                        curr_video.get("navigationEndpoint", {})
                        .get("commandMetadata", {})
                        .get("webCommandMetadata", {})
                        .get("url", "NA")
                    )
                    output["Link"] = "https://www.youtube.com" + url_
                    metadata += f"Link : {output['Link']}\n"

                    # Get Thumbnails from current video
                    thumbnails = curr_video.get("thumbnail", {}).get("thumbnails", {})
                    tmp = []
                    for t in thumbnails:
                        tmp.append(t["url"])
                    output["Thumbnails"] = tmp[0]
                    thumburl.append(output["Thumbnails"])
                    meta.append("\n\n" + metadata)
                    output["Location"] = ""

                    metadata = ""
                    del tmp

                    # Append current video to the final master list
                    final.append(output)
                    c += 1

        self.startThumbnailJob(thumburl, meta, final)

        return final

    def get_dict(self):
        return self.videos


# Command line args
parser = argparse.ArgumentParser()

# Add query to search
parser.add_argument("-q", type=str, default="neovim", help="Query to search.")

# Algorithm to Use
parser.add_argument("-a", type=str, default="v2", help="Algo to use v1 or v2")

args = parser.parse_args()

# Delete Cached Thumbnails
thumbDir = os.path.expanduser("~/.cache/thumbs")
os.system(f"rm -rf {thumbDir};mkdir -p {thumbDir}")

# Call the class
obj = searchYouTube(args.q, 20, args.a)

# Get json and store it in the user folder
jsonString = json.dumps(obj.get_dict(), indent=4)
path = "~/.cache/data.json"
with open(os.path.expanduser(path), "w") as f:
    f.write(jsonString)

Feed Reader
    by Eric S. Johnsen

===========================================================================
Description:

This is a simple syndication feed reader. It only supports feeds from one URL (http://feeds2.feedburner.com/TheTechnologyEdge).
It displays a list of articles in the root view controller along with their publish date. Selecting a row in the article table pushes a detail view controller onto the navigation stack which displays the article's HTML content.

This application uses the CoreData framework to store all articles published within the past two years. This allows content to be viewed offline, with the exception of images included in article content.

The most complicated logic is contained in SMParseFeedOperation.m. This is where the feed data is parsed and handled. It is heavily commented.

<!-- ********************************************** -->
<!-- This is an example of an article in the Feed 	-->
<!-- ********************************************** -->
<entry gd:etag="W/&quot;D0INSXkzcCp7ImA9WhNSF0o.&quot;">
	<id>tag:blogger.com,1999:blog-9190981816494400977.post-278712879300165338</id>
	<published>2012-10-30T07:58:00.000-05:00</published>
	<updated>2012-11-01T08:13:18.788-05:00</updated>
	<app:edited xmlns:app="http://www.w3.org/2007/app">2012-11-01T08:13:18.788-05:00</app:edited>
	<category scheme="http://www.blogger.com/atom/ns#" term="$Front" />
	<category scheme="http://www.blogger.com/atom/ns#" term="icstars" />
	<title>A Daily Splash of Star Talent</title>
	<content type="html">...</content>
	<link rel="replies" type="application/atom+xml" href="http://blogs.solstice-consulting.com/feeds/278712879300165338/comments/default" title="Post Comments" />
	<link rel="replies" type="text/html" href="http://www.blogger.com/comment.g?blogID=9190981816494400977&amp;postID=278712879300165338" title="0 Comments" />
	<link rel="edit" type="application/atom+xml" href="http://www.blogger.com/feeds/9190981816494400977/posts/default/278712879300165338?v=2" />
	<link rel="self" type="application/atom+xml" href="http://www.blogger.com/feeds/9190981816494400977/posts/default/278712879300165338?v=2" />
	<link rel="alternate" type="text/html" href="http://feedproxy.google.com/~r/TheTechnologyEdge/~3/rmiaMP77gOw/a-daily-splash-of-star-talent.html" title="A Daily Splash of Star Talent" />
	<author>
		<name>J Schwan</name>
		<email>noreply@blogger.com</email>
		<gd:image rel="http://schemas.google.com/g/2005#thumbnail" width="32" height="32" src="//lh4.googleusercontent.com/-4j67YCmqliM/AAAAAAAAAAI/AAAAAAAAAAA/xKuwkw1epJI/s512-c/photo.jpg" />
	</author>
	<media:thumbnail xmlns:media="http://search.yahoo.com/mrss/" url="http://2.bp.blogspot.com/-zskvsoV_AJw/UI_PMdzp4qI/AAAAAAAAACY/eDnzugWzxVE/s72-c/Screen+Shot+2012-10-30+at+7.58.46+AM.png" height="72" width="72" />
	<thr:total>0</thr:total>
	<feedburner:origLink>http://blogs.solstice-consulting.com/2012/10/a-daily-splash-of-star-talent.html</feedburner:origLink>
</entry>

===========================================================================
Included files description:

SMAppDelegate
Functions as the applications delegate. Downloads the feed data using an asynchronous NSURLConnection. Spawns our custom XML parsing operation.

SMParseFeedOperation
This is the 'heavy-lifer' of the application. Once downloaded in the application delegate, this operation parses the data using an NSXMLParser object.

SMFeedItem
The managed object model object to store our feed item data.

SMRootViewController
A simple table view controller that displays our list of feed items in our persistent store.

SMDetailViewController
A very simple view controller that displays a feed item's HTML content in a web view.
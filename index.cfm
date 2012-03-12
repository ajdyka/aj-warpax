<cfsetting enablecfoutputonly="true">
<cfcache Timespan="#createTimeSpan(0,0,10,0)#" />

<cfparam name="twitterfail" default="0">
<cfparam name="posterousfail" default="0">
<cfparam name="mangofail" default="0">

<cffeed source="http://twitter.com/statuses/user_timeline/10802412.rss" query="twitter" >
<cffeed source="http://ajdyka.posterous.com/rss.xml" query="posterous">
<!--- <cffeed source="http://aj.warpax.com/feeds/rss.cfm" query="mango"> --->
<cffeed source="http://twitpic.com/photos/ajdyka/feed.rss" query="twitpic">

<cfloop query="twitter">
	<cfset querySetCell(twitter,"source","twitter",twitter.currentRow)>
</cfloop>

<cfloop query="posterous">
	<cfset querySetCell(posterous,"source","posterous",posterous.currentRow)>
</cfloop>

<!--- <cfloop query="mango">
	<cfset querySetCell(mango,"source","mango",mango.currentRow)>
</cfloop> --->

<cfloop query="twitpic">
	<cfset querySetCell(twitpic,"source","twitpic",twitpic.currentRow)>
</cfloop>

<!--- Query of query to merge feed data --->
<cfquery dbtype="query" name="merger">
	SELECT *
	FROM twitter
	UNION
	SELECT *
	FROM posterous
	UNION
	<!--- SELECT *
	FROM mango
	UNION --->
	SELECT *
	FROM twitpic
</cfquery>

<cfset holder = arrayNew(1)>
<cfset QueryAddColumn(merger, "PublishedDateNew", holder)>

<cfloop query="merger">
	<cfset new_date = dateConvert('local2Utc',trim(right(left(merger.publishedDate,25),20)))>
	<cfset querySetCell(merger,"PublishedDateNew",new_date,merger.currentRow)>
</cfloop>

<cfquery dbtype="query" name="merger_sorted">
	select source, publishedDateNew, title, content 
	from merger
	order by PublishedDateNew desc
</cfquery>


<cfoutput>
<html>
	<head>

		<title>Refactored ... again</title>

		<link rel="stylesheet" href="refactor.css" type="text/css">

	</head>
<body>

<h1>AJ aggregated ...</h1>
<h3>(never aggravated!)</h3>

<cfloop query="merger_sorted" endrow='25'>
<div class="entry">
	<span class="date">#dateFormat(publishedDateNew,"mmm d yyyy")#</span>
	<cfif source EQ "posterous">
		<span class="title">#title#</span>
		<cfset info = reFind("[ajdyka&].posterous.com",content)>
		<span class="content">
		#left(content,info-26)#</span>
	<cfelseif source EQ 'twitter'>
		<span class="title">#right(title,len(title)-8)#</span>
	<cfelseif source EQ 'twitpic'>
		<span class="title">#right(content,len(content)-8)#</span>
	<cfelse>
		<span class="content">#content#</span>
	</cfif>
</div>
</cfloop>
</cfoutput>

</body>
</html>

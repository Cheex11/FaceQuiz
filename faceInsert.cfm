<cfif isDefined("url.method") and url.method CONTAINS "update">
	<cfquery datasource="#application.ds#" name="pull_correct">
		select count(lid) as [correct_answers] from face_score_Details where correct=1 and 
		frn_leuseradminid = #session.callmeasurementx_uid#
		and date_taken = convert(varchar(19),getDate(), 111)
	</cfquery>

    <cfquery name = "score_insert" datasource = "#application.ds#">
        update face_score
        set score = <cfqueryparam value='#pull_correct.correct_answers#' CFSQLType='CF_SQL_INTEGER'>, <!---<cfqueryparam value='#url.score#' CFSQLType='CF_SQL_INTEGER'>,--->
        time_remaining = <cfqueryparam value='#url.time_remaining#' CFSQLType='CF_SQL_TIME'>
        where frn_leuseradminid = #session.callmeasurementx_uid#
		and date_taken = convert(varchar(19),getDate(), 111)
    </cfquery>
	<!---added by IR 05/02/2015 to mark the remaining answers incorrect. I also changed face_quiz.cfc (the alteration is)
	commented) to only mark answers correct that are marked null - this should solve my hack I discovered, the scores should
	remain the same no matter what--->
	<cfquery name = "mark_incorrect" datasource = "#application.ds#">
        update face_score_Details
        set correct = 0
        where frn_leuseradminid = #session.callmeasurementx_uid#
		and date_taken = convert(varchar(19),getDate(), 111)
		and correct is null
    </cfquery>
</cfif>

<cfquery datasource = "callmeasurement" name = "pull_score">
    select leuseradminid,  website_avatar, adminname, score, time_remaining, start_time from face_score
	join leuseradmin on leuseradminid = frn_leuseradminid
	where date_taken = convert(varchar(19),getDate(), 111)
	order by score desc, time_remaining desc
</cfquery>

<cfquery datasource="#application.ds#" name = "pull_results">
	select website_avatar, face, lid, correct
	from face_score_details
		join leuseradmin on leuseradminid = lid
	where date_taken = convert(varchar(19),getDate(), 111)
		and frn_leuseradminid = #session.callmeasurementx_uid#
</cfquery>

<cfquery datasource = "#application.ds#" name = "pull_25">
	select adminname, score, time_remaining, website_avatar
	from face_score
		join leuseradmin on leuseradminid = frn_leuseradminid
	where score = 25
</cfquery>

<cfquery dbtype = "query" name = "pull_25_all">
	select distinct adminname, count(score) as total_amount, max(time_remaining) as best_time, website_avatar
	from pull_25
	group by adminname, score, website_avatar
	order by best_time desc
</cfquery>

<cfoutput>
	<div class = "results">
		<span>Your Results</span><br/>
		<cfloop query = "pull_results">
			<div class = "result-holder">
				<div class = "circle-result">
					<div class = "face-result">
						<img src = "//centuryinteractive.com/team/#pull_results.website_avatar#"/>
					</div>
				</div>
				<div class = "name-result">
					#pull_results.face#
				</div>
				<div class = "correct-results">
					<cfif pull_results.correct EQ 1>
						<img src="fx4-big-checkmark.png">
					</cfif>
				</div>
			</div>
		</cfloop>
	</div>
	
	<div class = "club">
		<span>Club 25</span><br/>
		<cfloop query = "pull_25_all">
		<div class = "25-holder">
			<div class = "circle-result">
				<div class = "face-result">
					<img src = "//centuryinteractive.com/team/#pull_25_all.website_avatar#"/>
				</div>
			</div>
			<div class = "25-name">
				#pull_25_all.adminname#
			</div>
			<div class = "25-amount">
				<strong>#pull_25_all.total_amount# times</strong>
			</div>
			<div class = "25-time">
				Most time remaining - #timeFormat(pull_25_all.best_time, 'H:mm')#
			</div>
		</div>
		</cfloop>
	</div>

	<div class = "leaderboard" style="display:inline-block">

		<span>Today's Leaderboard</span><br/><br/>
		<div class = "label label1">Place</div>
		<div class = "label label2">Name</div>
		<div class = "label label3">Score</div><br/>
		<cfloop query = "pull_score">
			<div class = "leaderboard-holder">
				<div class="participant-holder">
					<div class = "place">
						#pull_score.currentRow# &nbsp
					</div>
					<div class="participant <cfif pull_score.leuseradminid EQ session.callmeasurementx_uid>your-face</cfif>">
						<img src = "//centuryinteractive.com/team/#pull_score.website_avatar#">
					</div>
					&nbsp #pull_score.adminname#
				</div>
				<div class = "participant-score">
					<cfif dateDiff("s", pull_score.start_time, now()) GT 90 and pull_score.time_remaining EQ "">
						<span>Cheater
					<cfelseif dateDiff("s", pull_score.start_time, now()) LT 90 and pull_score.time_remaining EQ "">
						In Progress
					<cfelse>
					<strong>#pull_score.score#</strong> <cfif pull_score.score EQ 25>@ #timeFormat(pull_score.time_remaining, 'H:mm')#</cfif>
					</cfif>
				</div>
			</div>
		</cfloop>
	</div>
</cfoutput>

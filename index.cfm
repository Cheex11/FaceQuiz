<cfquery datasource = "callmeasurement" name = "pull_admin">
	select top 9 leuseradminid, website_avatar
	from leuseradmin
	where isactive = 'yes'
	and website_avatar is not null
	order by NEWID()
</cfquery>

<cfquery datasource = "callmeasurement" name = "already_taken">
	select date_taken from face_score
	where frn_leuseradminid = #session.callmeasurementx_uid#
</cfquery>

<cfquery datasource = "callmeasurement" name = "pull_score">
	select leuseradminid,  website_avatar, adminname, score, time_remaining, start_time from face_score
	join leuseradmin on leuseradminid = frn_leuseradminid
	where date_taken = convert(varchar(19),getDate(), 111)
	order by score desc, case when time_remaining is null then 0 else 1 end desc
</cfquery>
<html>
<head>

	<title>Face Quiz</title>
	
	<link href='http://fonts.googleapis.com/css?family=Roboto:400,300,700' rel='stylesheet' type='text/css'>
	
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
	
	<script language = "Javascript">
	
	$(document).ready(function() {
		$('.face-circle:first').css("height", "15px").css("width", "15px");
		$('.face-circle:last').css("height", "15px").css("width", "15px");
		$('.face-circle:eq(1)').css("height", "25px").css("width", "25px");
		$('.face-circle:eq(7)').css("height", "25px").css("width", "25px");
		$('.face-circle:eq(2)').css("height", "35px").css("width", "35px");
		$('.face-circle:eq(6)').css("height", "35px").css("width", "35px");
		$('.face-circle:eq(3)').css("height", "45px").css("width", "45px");
		$('.face-circle:eq(5)').css("height", "45px").css("width", "45px");
	});
	
	</script>
	
	<style>
	
		html, body {
			background-color: #e5e5e5;
			font-family: 'Roboto', sans-serif;
			margin: 0px;
			text-align: center;
			width: 100%; height: 100%;	
			 -webkit-user-select: none;
			  -moz-user-select: none;
			  -ms-user-select: none;
			  -o-user-select: none;
			  user-select: none;  
		}
		
		a {
		  text-decoration: none;
		}
		
		.title {
			display: inline-block;
			background-color: white;
			text-align: center;
			border: solid 1px #c4c4c4;
			border-radius: 3px;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
			font-size: 60px;
			margin-top: 50px;
			padding: 25px;
		}
		
		.container {
			background-color: white;
			border: solid 1px #c4c4c4;
			border-radius: 3px;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
			display: inline-block;
			padding: 30px;
			margin-top: 20px;
		}
		
		.rules {
			text-align: center;
			font-size: 25px;
		}
		.rules p { margin: 0px; padding-bottom: 12px; }
		
		.holder {
			width: 100%;
			display: block;
		}
		
		.start {
			background-color: #007EEF;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
			border-radius: 3px;
			text-align: center;
			display: inline-block;
			padding: 15px 25px;
			margin-top: 20px;
			font-weight: 700;
			font-size: 15px;
			text-transform: uppercase;
			cursor: pointer;
		}
		
		.start:hover {
			background-color: #009DEF;
		}
		
		.start div {
			color: white;
		}

		.face-holder { 
			text-align: center; 
			padding-top: 14px;
			display: block;
			line-height: 0px;
		}
		
		.faces { 
			text-align: center; 
			padding-top: 14px;
			line-height: 0px;
			display: inline-block;
			margin: 0px 10px;
		}
		
		.face-circle {
			position: relative;
			display: block;
			-moz-border-radius: 50%;
			-webkit-border-radius: 50%;
			border-radius: 50%;
			border: solid 1px #c4c4c4;
			width: 50px;
			height: 50;
			margin: 10px 0px;
			overflow: hidden;
		}
		.face-circle img {
			display: block; 
			width: 100%;
		}
		
		.desktop-content { display: block; }
		.mobile-message { display: none; margin-top: 40px; }
		
		@media (max-width: 920px) {
			.desktop-content { display: none; }
			.mobile-message { display: block; }
		}
		
		.wait {
			margin-top: 100px;
		}
		
		.leaderboard { 
			text-align: left; padding-top: 14px; 
			display: none;
			margin-top: 25px;
			margin-bottom: 50px;
			background-color: white;
			padding: 25px;
			border: solid 1px #c4c4c4;
			border-radius: 3px;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
		}
		
		.participant {
			display: inline-block;
			-moz-border-radius: 50%;
			-webkit-border-radius: 50%;
			border-radius: 50%;
			border: solid 1px #c4c4c4;
			width: 25px;
			height: 25px;
			margin: 10px 0px;
			overflow: hidden;
			vertical-align: middle;
		}
		.participant img {
			display: block; 
			width: 100%;
		}
		
		.participant-holder {
			display: inline-block;
			text-align: center;
			vertical-align: middle;
			vertical-align: middle;
			padding-right: 20px;
		}
		
		.leaderboard-holder {
			vertical-align: middle;
			background-color: white;
			display: block;
			border-bottom: 1px solid #c4c4c4;
		}
		.leaderboard-holder:last-child { border-bottom: 0px solid #c4c4c4; }
		
		.leaderboard span {
			text-align: center;
			display: block;
			font-size: 30px;
			font-weight: 700px;
		}
		
		.participant-score {
			float: right;
			display: inline-block;
			vertical-align: middle;
			padding: 5px;
			margin-top: 8px;
		}
		
		.holder {
			width: 100%;
			background-color: #e5e5e5;
			display: none;
		}
		
		.place {
			vertical-align: middle;
			display: inline-block;
			font-weight: 700;
		}
		
		.your-face .participant {
			width: 50px;
			height: 50px;
		}
		.your-face + .participant-score { 
			margin-top: 20px;
		}
		
		.label {
			display: inline-block;
			vertical-align: middle;
			font-weight: 700;
			font-size: 20px;
			margin-right: 40px;
			border-bottom: solid 1px #c4c4c4;
		}
		
		.label3 {
			margin-left: 30px;
			margin-right: 0px;
		}

		.participant-score span{
			color: #d73838;
			font-size: 20px;
			font-weight: 600;
		}
		
	</style>
	
</head>
<body>
<cfif already_taken.date_taken EQ dateFormat(now(),"yyyy-mm-dd")>
		<div class = "wait">
			You must wait until tomorrow to re-take the quiz
		</div>
		<div class = "leaderboard" style="display:inline-block">
			<cfoutput>
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
					<span>Cheater</span>
				<cfelseif dateDiff("s", pull_score.start_time, now()) LT 90 and pull_score.time_remaining EQ "">
					In Progress
				<cfelse>
				<strong>#pull_score.score#</strong><cfif pull_score.score EQ 25> @ <strong>#timeFormat(pull_score.time_remaining, 'H:mm')#</strong></cfif>
				</cfif>
			</div>
		</div>
	</cfloop>
</cfoutput>
		</div>
	<cfelse>
<div class="mobile-message">You need a larger screen in order to play...</div>
<div class="desktop-content">
	<div class = "holder1">
		<div class = "title">
			Face Quiz
		</div>
	</div>
	<div class = "face-holder">
		<cfloop query = "pull_admin">
			<cfoutput>
				<div class = "faces">
					<div class = "face-circle">
						<img src = "//centuryinteractive.com/team/#pull_admin.website_avatar#">
					</div>
				</div>
			</cfoutput>
		</cfloop>
	</div>
	<div class = "container">
		<div class = "rules">
			<p>One and a half minutes. Twenty-five faces.</p>
			<p>Perfect spelling required.</p>
			<p>First and last name.</p>
			<p>One attempt per day.</p>
			<p>Refreshing or leaving the page will mark you a cheater.</p>
		</div>
		<a class = "start" href = "http://go.centuryinteractive.com/go/face_quiz/facequiz.cfm">
			<div>
				Start
			</div>
		</a>
	</div>
</div>
</cfif>
</body>
</html>
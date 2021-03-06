<cfquery datasource = "callmeasurement" name = "pull_admin">
	select top 25 leuseradminid, adminname, website_avatar
	from leuseradmin
	where isactive = 'yes'
	and website_avatar is not null
	and leuseradminid <> #session.callmeasurementx_uid#
	and (team_ci = 1 or team_leadtag = 1)
	order by NEWID()
</cfquery>

<cfquery datasource = "#application.ds#" name = "pull_score">
	select leuseradminid,  website_avatar, adminname, score, time_remaining, start_time from face_score
	join leuseradmin on leuseradminid = frn_leuseradminid
	where date_taken = convert(varchar(19),getDate(), 111)
	order by score desc, case when time_remaining is null then 0 else 1 end desc
</cfquery>

<cfquery datasource = "#application.ds#" name = "already_taken">
	select date_taken from face_score
	where frn_leuseradminid = #session.callmeasurementx_uid#
	and date_taken = convert(varchar(19),getDate(), 111)
</cfquery>

<cfif already_taken.recordCount EQ 0>
	<cfquery datasource = "#application.ds#">
		insert into face_score (frn_leuseradminid, score, time_remaining)
		values (#session.callmeasurementx_uid#, 0, NULL)
	</cfquery>

	<cfloop query = "pull_admin">
		<cfquery datasource = "#application.ds#">
			insert into face_score_details (frn_leuseradminid, date_taken, face, lid)
			values (#session.callmeasurementx_uid#, convert(varchar(19),getDate(), 111), '#adminname#', #leuseradminid#)
		</cfquery>
	</cfloop>
</cfif>

<cfquery datasource="#application.ds#" name = "pull_results">
	select website_avatar, face, lid, correct
	from face_score_details
		join leuseradmin on leuseradminid = lid
	where date_taken = convert(varchar(19),getDate(), 111)
		and frn_leuseradminid = #session.callmeasurementx_uid#
</cfquery>

<html>

<head>
	<title>Faces Quiz</title>
	
	<link href='http://fonts.googleapis.com/css?family=Roboto:400,300,700' rel='stylesheet' type='text/css'>
	
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
    <script src="http://crypto-js.googlecode.com/svn/tags/3.1.2/build/rollups/sha256.js"></script>
	
	<cfset adminid = session.callmeasurementx_uid>
	
	<cfajaxproxy cfc="face_quiz" jsclassname="score">
	<script language = "Javascript">

	var numCorrect = 0;
	
	$(window).load(function() {
		$('.loading').slideUp(500,function(){
			timer_start();
		});
	});
	
	$(document).ready(function(){
		<cfif already_taken.date_taken EQ dateFormat(now(),"yyyy-mm-dd")>
			scoreSubmit();
		</cfif>
	
		$(window).on('keydown',function(event){
			var inputValue = $('.Input').val();
			var keyCode = event.keyCode;
			
			if ($('.active-face').hasClass('complete-face')) {
				$('.Input').val('');
			}
			
			if(keyCode == 40 || keyCode == 13){
				$('.Input').val('');
				scrollDown();
			}
			else if(keyCode == 38){
				$('.Input').val('');
				scrollUp();
			}
		});
		
		$(window).on('keyup',function(event){
			var input = $('.Input').val();
			var inputValue = input.toLowerCase();
			var update_face=new score();
			var total = 25;
			var pic = namearray[$(".active-face").data("index")-1];
			var adminid = $(".active-face").find(".adminid").text();
			if (CryptoJS.SHA256(inputValue.concat(pic[1])).toString(CryptoJS.enc.Hex).toLowerCase() === pic[0].toLowerCase()) {
				numCorrect = numCorrect + 1;
				$('.faces_left').text(numCorrect + " " + "out of" + " " + total);
				$('.active-face').addClass('complete-face');
				$('.Input').val('');
				<cfoutput>
					update_face.update_score(#session.callmeasurementx_uid#, adminid);
				</cfoutput>
				scrollDown();
			}
			if (numCorrect == 25) {
				scoreSubmit();
				clearInterval(counter);
				$(".wrapper").replaceWith($(".holder")).addClass('end');
				$(".holder").css("display", "block");
				$('.leaderboard').css("display", "inline-block");
			};
		});
		
		var facesCount = 5;
	
		for(i=1;i<=facesCount;i++){
			var faceIndex = i - 1;
			$('.face-circle:eq(' + faceIndex + ')').css("display","inline-block");
		}
		
		$('.face-circle:eq(2)').removeClass('inactive-face').addClass('active-face');
		$('.Input').focus();

		$('.down-arrow-btn').click(function() {
			scrollDown();
		});
		
		$('.up-arrow-btn').click(function() {
			scrollUp();
		});
		
		$('.give-up-btn').click(function() {
			scoreSubmit();
			clearInterval(counter);
			$(".wrapper").replaceWith($(".holder")).addClass('end');
			$(".holder").css("display", "block");
			$('.leaderboard').css("display", "inline-block");
		});
	});
	
	var counter;
	
	function timer_start() {
		var count = 90;
		counter = setInterval(timer, 1000);
		function timer() {
			var minutes = Math.floor(count / 60);
			var seconds = count % 60;
			if(seconds <= 9){
				seconds = "0"+ seconds;
			}	
			$('#timer').text(minutes + ":" + seconds);
			console.log(count);
			count--;
			
			if (count < 0) {
				scoreSubmit();
				clearInterval(counter);
				$(".wrapper").replaceWith($(".congrats")).addClass('end');
				$(".holder").css("display", "block");
				$('.leaderboard').css("display", "inline-block");
				
				var facesCount = 60;
	
				for(i=1;i<=facesCount;i++){
					var faceIndex = i - 1;
					$('.participant-holder:eq(' + faceIndex + ')').css("display","inline-block");
				}
			}	
		}
	}
	
	function scrollDown(){
		if($('.face-circle:visible:last').is(':not(:last-child)')){
			$('.active-face').removeClass('active-face').addClass('inactive-face');
			$('.face-circle:visible:eq(3)').removeClass('inactive-face').addClass('active-face');
			$('.face-circle:visible:first').css("display","none");
			$('.face-circle:visible:last').next().next().css("display","inline-block");
		}
	}
	
	function scrollUp(){
		if($('.face-circle:visible:first').is(':not(:first-child)')){
			$('.active-face').removeClass('active-face').addClass('inactive-face');
			$('.face-circle:visible:eq(1)').removeClass('inactive-face').addClass('active-face');
			$('.face-circle:visible:last').css("display","none");
			$('.face-circle:visible:first').prev().prev().css("display","inline-block");
		}
	}
	
	function scoreSubmit() {
		<cfif already_taken.date_taken EQ dateFormat(now(),"yyyy-mm-dd")>
			var method = "list";
		<cfelse>
			var method = "update";
		</cfif>
	
	
		var time_remaining = $('#timer').text();
		//console.log(time_remaining);
		$.ajax ({
			url: "faceInsert.cfm",
			data: {
				score : numCorrect,
				time_remaining : time_remaining,
				method : method
			},
			success: function(result){
				$('.results-section').empty();
				$('.results-section').append(result);
				$('.congrats p').empty();
				$('.congrats p').text('You guessed' + ' ' + numCorrect + ' ' + 'with' + ' ' + time_remaining + ' ' + 'left');
			}			
		});
		
	}
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
		
		.end {
			text-align: center; 
			vertical-align: middle;
			padding-top: 200px;
			font-size: 50px;
		}
		
		.wrapper { width: 100%; height: 100%; z-index: 1;}
		.wrapper td { width: 100%; height: 100%; text-align: center; vertical-align: middle; }
		
		.container {  
			display: inline-block;
			width: 100%;
			max-width: 1000px;
		}
		
		.left-section {
			position: relative;
			display: inline-block;
			vertical-align: middle;
			width:40%;
		}
		.left-section-inner {
			display: block; 
			padding: 20px;
			border-right: solid 1px #c4c4c4;
		}
		
		.Name_game {
			color: #3c3c3c;
			font-family: Roboto;
		}
		
		.timer, .faces_correct {
			position: relative;
			border: solid 1px #cccccc;
			-moz-border-radius: 100px;
			-webkit-border-radius: 100px;
			border-radius: 100px;
			background-color: white;
			margin: 30px 0px;
			text-align: left;
		}
		
		.left-icon-holder {
			display: inline-block; vertical-align: middle;
			margin: 12px; padding: 12px;
			background-color: #c4c4c4;
			-moz-border-radius: 50%;
			-webkit-border-radius: 50%;
			border-radius: 50%;
		}
		
		.time_left {
			display: inline-block;
			vertical-align: middle; 
			margin-left: 30px;
			font-weight: bold;
			font-size: 60px;
		}
		
		.faces_left {
			display: inline-block;
			vertical-align: middle; 
			font-weight: bold;
			font-size: 40px;
		}
		
		.give-up-btn {
			display: inline-block; padding: 8px 12px;
			border: solid 1px #c22e2e;
			color: #c22e2e;
			font-size: 12px; 
			font-weight: 600;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
			border-radius: 3px;
			cursor: pointer; 
		}
		
		.faces-form {  
			display: inline-block; vertical-align: middle;
			margin-right: 15px;
			text-align: left;
		}
		
		.faces-form h3{
			margin: 8px 0px;
			font-size: 30px;
			font-weight: 300;
			color: #3c3c3c;
		}
		
		faces-buttons{
			display: inline- block;
			vertical-align: middle;
		}
		
		.enter-button {
			display: inline-block;
			border: solid 1px #c4c4c4;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
			border-radius: 3px;
			padding: 3px;
			vertical-align: middle;
			margin-right: 5px;
		}
		
		.down-button {
			display: inline-block;
			border: solid 1px #c4c4c4;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
			border-radius: 3px;
			padding: 3px;
			vertical-align: middle;
			margin-right: 5px;
			margin-left: 5px;
		}
		
		.faces-container { 
			display: inline-block; 
			vertical-align: middle;
		}
		
		.faces-holder {
			display: inline-block; 
			vertical-align: middle;
			width: 178px; 
			height: 489px;
			background: url('fx4-faces-background-2.png');
		}
		
		.faces { 
			text-align: center; 
			padding-top: 14px;
			width: 178px; 
			height: 489px; 
			line-height: 0px;
		}
		
		.face-circle {
			position: relative;
			display: inline-block;
			-moz-border-radius: 50%;
			-webkit-border-radius: 50%;
			border-radius: 50%;
			border: solid 1px #c4c4c4;
			width: 125px;
			height: 125px;
			margin: 10px 0px;
			overflow: hidden;
		}
		
		.face-image {
			display: block; width: 100%;
			
		}
		
		.complete-face {
			opacity: 0.4;
		}
		
		.empty-face { visibility: hidden; width: 55px; height: 55px;  }
		
		.inactive-face { 
			display: none;  width: 55px; height: 55px;
			-webkit-transition: all 0.5s ease;
			-moz-transition: all 0.5s ease;
			-o-transition: all 0.5s ease;
			transition: all 0.5s ease;
		}
		.active-face { 
			display: inline-block; 
			width: 125px; 
			height: 125px; 
			-webkit-transition: all 0.5s ease;
			-moz-transition: all 0.5s ease;
			-o-transition: all 0.5s ease;
			transition: all 0.5s ease;
		}
		
		.faces-arrow-button {
			display: block; text-align: center; margin: 10px; cursor: pointer;
		}
		
		
		.give-up-btn:active {
			-ms-transform: translateY(2px);
			-webkit-transform: translateY(2px);
			transform: translateY(2px);
		}

		.right-section {
			position: relative;
			display: inline-block;
			vertical-align: middle;
			width: 60%;
		}
		
		.right-section-inner {
			display: block;
		}
		
		.Input {
			background-color: white;
			border-radius: 3px;
			border-style: solid;
			border-width: 1px;
			border-color: #cccccc;
			height: 40px;
			width: 200px;
			padding: 5px;
			font-size: 20px;
			outline: none;
		}
		
		.wait {
			padding-top: 100px;
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
		
		.completed-checkmark {
			display: none; position: absolute; width: 25px !important; height: 25px; top: 50%; left: 50%;
			margin-top: -13px; margin-left: -13px; background-color: #ffffff; 
			-moz-border-radius: 50%; -webkit-border-radius: 50%; border-radius: 50%;
			border: solid 2px #4CB849;
		}
		
		.complete-face .completed-checkmark { 
			display: block; 
		}
		
		.leaderboard-holder {
			vertical-align: middle;
			background-color: white;
			display: block;
			border-bottom: 1px solid #c4c4c4;
		}
		
		.leaderboard-holder:last-child { 
			border-bottom: 0px solid #c4c4c4; 
		}
		
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
		
		.participant-score span{
			color: #d73838;
			font-size: 20px;
			font-weight: 600;
		}
		
		.congrats {
			display: inline-block;
			margin-top: 20px;
			background-color: white;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
			border-radius: 3px;
			border: solid 1px #c4c4c4;
			text-align: center;
			font-size: 30px;
			padding: 30px;
		}
		
		.congrats p, .congrats span {
			margin: 0px;
			font-size: 24px;
		}
		
		.study {
			display: block;
			background-color: #007EEF;
			color: white;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
			border-radius: 3px;
			border: solid 1px;
			text-align: center;
			padding: 15px;
			margin-top: 20px;
			font-weight: 700;
			font-size: 15px;
			text-transform: uppercase;
			text-decoration: none;
			cursor: pointer;
		}
		
		.study:hover {
			background-color: #009DEF;
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
		
		.desktop-content { display: block; z-index: 1;}
		.mobile-message { display: none; margin-top: 40px; }
		
		@media (max-width: 920px) {
			.desktop-content { display: none; }
			.mobile-message { display: block; }
		}
		
		.loading {
			width: 100%;
			height: 100%;
			background-color: white;
			z-index: 3;
			position: fixed;
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
		
		.adminid {
			visibility: hidden;
		}
		
		.results {
			vertical-align: top;
			text-align: left; 
			padding-top: 14px; 
			display: inline-block;
			margin-top: 25px;
			margin-bottom: 50px;
			margin-right: 50px;
			background-color: white;
			padding: 25px;
			border: solid 1px #c4c4c4;
			border-radius: 3px;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
		}
		
		.results span {
			text-align: center;
			display: block;
			font-size: 30px;
			font-weight: 700px;
		}
		
		.name-result {
			display: inline-block;
			vertical-align: middle;
			margin: 0px 5px;
		}
		
		.correct-results {
			display: inline-block;
			vertical-align: middle;
		}
		
		.correct-results img {
			width: 25px;
			height: 25px;
		}
		
		.circle-result {
			display: inline-block;
			-moz-border-radius: 50%;
			-webkit-border-radius: 50%;
			border-radius: 50%;
			border: solid 1px #c4c4c4;
			width: 50px;
			height: 50px;
			margin: 10px 5px;
			overflow: hidden;
			vertical-align: middle;
		}
		
		.circle-result img {
			display: block; 
			width: 100%;
		}
		
		.result-holder {
			display: block;
			padding: 10px;
			border-bottom: solid 1px #c4c4c4;
		}
		
		.result-holder:last-child { 
			border-bottom: 0px solid #c4c4c4; 
		}
		
		.club {
			vertical-align: top;
			text-align: center; 
			padding-top: 14px; 
			display: inline-block;
			margin-top: 25px;
			margin-bottom: 50px;
			margin-right: 50px;
			background-color: white;
			padding: 25px;
			padding-left: 100px;
			padding-right: 100px;
			border: solid 1px #c4c4c4;
			border-radius: 3px;
			-moz-border-radius: 3px;
			-webkit-border-radius: 3px;
		}
		
		.club span {
			text-align: center;
			display: block;
			font-size: 40px;
			font-weight: 700px;
			border-bottom: 1px solid #c4c4c4;
		}
		
		.25-name, .25-amount, .25-time {
			display: inline-block;
		}
		
		.25-holder {
			display: block;
			padding: 10px;
			border-bottom: solid 1px #c4c4c4;
			width: 300px;
			margin-bottom: 15px;
		}
		
		.25-holder:last-child { 
			border-bottom: 0px solid #c4c4c4; 
		}
	</style
	
	

</head>

<body>
<div class="mobile-message">You need a larger screen in order to play...</div>

<div class = "loading">
	Loading...... Please Wait
</div>

<div class="desktop-content">

	<cfif already_taken.date_taken EQ dateFormat(now(),"yyyy-mm-dd")>
		<div class = "wait">
			You must wait until tomorrow to re-take the quiz
		</div>
		<!---<cfoutput>
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
		</cfoutput>--->
		<div class="results-section">
			Loading...
		</div>	
	<cfelse>

	<table class="wrapper">
		<td>
			<div class="container">
				<div class = "left-section">
					<div class="left-section-inner">
						<h1 class = "Name_game">Face Quiz</h1>
						<div class = "timer">
							<div class="left-icon-holder">
								<img src="fx4-big-hourglass.png"/>
							</div>
							<div class = "time_left">
								<span id="timer"></span>
							</div>
						</div>
						<div class = "faces_correct">
							<div class="left-icon-holder">
								<img src="fx4-big-checkmark.png">
							</div>
							<div class = "faces_left">
							</div>
						</div>
						<div class = "give-up-btn">
							GIVE UP
						</div>
					</div>
				</div><div class = "right-section">
					<div class="right-section-inner">
						<div class="faces-form">
							<h3>Who is this?</h3>
							<form onsubmit="return false;">
								<input type = "text" class = "Input" onpaste="return false"></input>
							</form>
							<div class = "faces-buttons">
								<div class = "enter-button">
									Enter
									<img src="fx4-enter-arrow.png">
								</div>
								or
								<div class = "down-button">
									<img src="fx4-down-arrow.png">
								</div>
								to skip
							</div>
						</div>
						<div class="faces-container">
							<div class="up-arrow-btn faces-arrow-button">
								<img src="fx4-faces-up-arrow-btn.png"/>
							</div>
							<div class="faces-holder">
								<div class="faces">
									<div class="face-circle empty-face inactive-face complete-face"></div><br/>
									<div class="face-circle empty-face inactive-face complete-face"></div><br/>
									<cfoutput>
									<cfset namearray = ArrayNew(1)>
										<cfloop query = "pull_admin">
											<div class="face-circle inactive-face" data-index = "#pull_admin.currentRow#">
												<img class="completed-checkmark" src="fx4-big-checkmark.png">
												<img class="face-image" src = "//centuryinteractive.com/team/#pull_admin.website_avatar#">
												<div class = "adminid">#pull_admin.leuseradminid#</div>
											</div><br/>
                                            <cfset namesalt = CreateUUID()>
											<cfset namearray[#pull_admin.currentRow#] = [Hash(Lcase(#pull_admin.adminname#) & namesalt, "SHA-256"), namesalt]>
										</cfloop>
									</cfoutput>
									<div class="face-circle empty-face inactive-face complete-face"></div><br/>
									<div class="face-circle empty-face inactive-face complete-face"></div>
								</div>
								<script>										
									<cfoutput>
										 var #toScript(namearray, "namearray")#;
									</cfoutput>
								</script>
							</div>
							<div class="down-arrow-btn faces-arrow-button">
								<img src="fx4-faces-down-arrow-btn.png"/>
							</div>
						</div>
					</div>
				</div>
			</div>
		<td>
	</table>
	<div class="holder">
		<div class = "congrats">
			<p>Check your place below</p>
			<a class = "study" href = "http://go.centuryinteractive.com/admin/employee_directory.cfm">
				Study Up!
			</a>
		</div>
	</div>
	<div class="results-section">
		Loading...
	</div>	
</div>
</body>
</cfif>
</html>

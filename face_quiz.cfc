component {
//05/02/2015 IR added the  'and correct is null' filter so answers can only be submitted once.
	remote function update_score(curr_admin,adminid) {
		samplequery = new query();
		samplequery.setDatasource("callmeasurement");
		samplequery.setName("update_score");
		result = samplequery.execute(sql="update face_score_details set correct = 1 where lid = "&adminid&" and frn_leuseradminid="&curr_admin&" and date_taken = convert(varchar(19),getDate(), 111) and correct is null");
	}
	
}
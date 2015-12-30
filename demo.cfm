<cfinclude template="upload_functions.cfm">

<!---

	This demo dumps the uploaded files into the same directory as this file. (Don't do that in production)

	Notice that all you need to do on the client side is add the multiple="multiple" attribute
	 to your file field.
--->


<cfoutput>

<cfif isDefined("theFiles")>
	<cfset uploadedFiles = UploadMultipleFiles("thefiles", expandPath("."))>

	<p>
		You uploaded #Arraylen(uploadedFiles)# files!
	</p>

	<cfdump var="#uploadedFiles#">
</cfif>


<form method="post" enctype="multipart/form-data">
	<input name="thefiles" type="file" multiple="multiple" />

	<input type="submit" value="Submit">
</form>

</cfoutput>
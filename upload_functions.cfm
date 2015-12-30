<!---
	How it works:

	Uploaded files are placed in a temporary directory.
	The locations of those files are visible in the form structure.
	The trouble is, they have a random name; you can't even tell the extension.
	If you look at the hidden function form.getPartsArray(), you can see in depth just what was submitted.
	From this, we can get the file's name, and combine that with the info in the form struct.
	Then, we just copy the file to where we want it to be.
--->


<cffunction name="UploadMultipleFiles" output="false" returntype="array"
		description="Takes multiple file uploads in a single field.">

	<cfargument name="uploadFieldName" type="string" required="true">
	<cfargument name="uploadDir" type='string' required="true">

	<cfif not len(form[arguments.uploadFieldName])>
		<cfreturn ArrayNew(1)>
	</cfif>

	<cfset var uploadedFiles = GetAllUploadedFiles()[arguments.uploadFieldName]>
	<cfset var uploadedFile = ''>
	<cfset var ret = ArrayNew(1)>

	<cfloop array="#uploadedFiles#" index="uploadedFile">
		<cfset var fileName = moveFile(uploadedFile.localFile, arguments.uploadDir, uploadedFile.fileName)>
		<cfset ArrayAppend(ret, fileName)>
	</cfloop>

	<cfreturn ret>
</cffunction>



<cffunction name="GetAllUploadedFiles" output="false" returntype="struct"
		description="Returns all uploaded files, keyed by the field name. This supports multi-file uploads">

	<cfset var ret = StructNew()>
	<cfset var part = -1>
	<cfset var name = "">

	<!--- reach into the internals and pluck out the names of the files that were uploaded --->
	<cfloop index="part" array='#form.getPartsArray()#'>
		<cfif part.isFile()>
			<cfset name = part.getName()>
			<cfif not StructKeyExists(ret, name)>
				<cfset ret[name] = ArrayNew(1)>
			</cfif>
			<cfset ArrayAppend(ret[name], {localFile: "" ,fileName: part.getFileName()})>
		</cfif>
	</cfloop>

	<!--- The uploaded file itself is found in the form struct --->
	<cfset var localFile = "">
	<cfloop collection="#ret#" item="name">
		<cfset var localFiles = form[name]>
		<cfset var i = 0>
		<cfloop index="localFile" list="#localFiles#">
			<cfset i += 1>
			<cfset ret[name][i].localFile = localFile>
		</cfloop>
	</cfloop>

	<cfreturn ret>
</cffunction>


<cffunction name="moveFile" access="private" output="false" returntype="string"
		hint="Moves a file to a final location while preventing name conflicts. Returns the unique filename">

	<cfargument name="sourceFilePath" required="true" type="string" hint="Path to the existing file">
	<cfargument name="destinationDirectory" required="true" type="string" hint="Path to the destination directory">
	<cfargument name="fileName" default="">
	<!--- Extract the filename from the source path if not passed in --->
	
	<cfif arguments.fileName eq ''>
		<cfset arguments.filename = getFileFromPath(arguments.sourceFilePath)>
	</cfif>
	<cfset var counter = 1>
	<cfset var uniqueFileName = "">
	<cfset var destinationFilePath = "">
	<!--- Create an exclusive lock specific to the target directory --->
	<cflock type="exclusive" timeout="30" name="#destinationDirectory#">
		<!--- If a file with the same name already exists at the destination --->
		<cfif fileExists(destinationDirectory & "/" & filename)>
			<!--- Loop up to 500 times to try create a unique filename --->
			<cfloop condition="counter LT 500">
				<cfset destinationFilePath = destinationDirectory & "/" & counter & "_" & filename>
				<cfif fileExists(destinationFilePath)>
					<cfset counter++>
				<cfelse>
					<cfset uniqueFileName = counter & "_" & filename>
					<cfbreak/>
				</cfif>
			</cfloop>
			<!--- Filename does not already exist at the destination --->
		<cfelse>
			<cfset uniqueFileName = filename>
			<cfset destinationFilePath = destinationDirectory & "/" & filename>
		</cfif>
		<!--- Provided the filename is not already in use at the destination or a unique filename was generated we can perform the move --->
		<cfif len(trim(uniqueFileName))>
			<cffile action="move" source="#sourceFilePath#" destination="#destinationFilePath#">
		<cfelse>
			<cfthrow message="Unable to move the file and create a unique filename at the destination">
		</cfif>
	</cflock>
	<cfreturn uniqueFileName>
</cffunction>

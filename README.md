# multifile-upload
Upload multiple files to ColdFusion, using normal HTML5

## Usage

Make sure that you have the multiple attribute on your form's file upload field.

```html
<input name="fieldname" type="file" multiple="multiple" />
```

Then, on the page that receives the form submission, make the following function call:

```
uploadedFiles = UploadMultipleFiles("fieldname", directoryToUploadTo)
```

The function will return an array of the paths to the newly uploaded files.

## How does it work?

The library uses some hidden functions of the form object to look directly at the submitted form data,
then correlates this with the temporary files that were created from the upload.
Then it moves those files to the desired directory, keeping as close to the uploaded filename as possible.

# AWS S3 notes

Note this assumes that you have already installed the AWS CLI and configured your credentials.

## Copy from bucket using CLI

First, of in order to `copy` all objects within an `s3` bucket to your **local** machine we can use the following,

```bash
aws s3 cp s3://my-bucket/ ./ --recursive
```

This copies **all** contents of `my-bucket` to my current directory. Note, it is important to use `--recursive` option
in order to get all contents, not just the first level ones.

To get a folder within a bucket and its associated contents, we can use the following:

```bash
aws s3 cp s3://my-bucket/my-folder/ ./ --recursive
```

You can also use wildcards and patterns to filter which files to copy and/or exclude. An example of such command is:

```bash
aws s3 cp s3://my-bucket/ ./ --recursive --include --exclude "my-folder/*" --include "*.csv"
```

This **excludes** the contents of `my-folder` within the bucket and *only* **includes** copying files that enc with
the `.csv` extension.

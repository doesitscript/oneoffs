###### EC2 AMI Data Source Attributes
Name
	
AMI name
	
AMI ID
	
Source
	
Owner
	
Visibility
	
Status
	
Creation date
	
Platform
	
Root device type
	
Block devices
	
Virtualization
	
Deprecation time
	
Last launched time
	
Deregistration protection
	
Source AMI ID
	
Source AMI Region

GoldenAMI
amidistribution-2025-10-31T17-22-51.766Z
ami-051537eaae7545f75
422228628991/amidistribution-2025-10-31T17-22-51.766Z
422228628991
Private
 Available

2025/10/31 12:44 GMT-5
Windows
ebs
/dev/sda1=snap-0ca6c7a4768dc2854:100:true:gp3:encrypted, xvdca=ephemeral0, xvdcb=ephemeral1, xvdcc=ephemeral2, xvdcd=ephemeral3, xvdce=ephemeral4, xvdcf=ephemeral5, xvdcg=ephemeral6, xvdch=ephemeral7, xvdci=ephemeral8, xvdcj=ephemeral9, xvdck=ephemeral10, xvdcl=ephemeral11, xvdcm=ephemeral12, xvdcn=ephemeral13, xvdco=ephemeral14, xvdcp=ephemeral15, xvdcq=ephemeral16, xvdcr=ephemeral17, xvdcs=ephemeral18, xvdct=ephemeral19, xvdcu=ephemeral20, xvdcv=ephemeral21, xvdcw=ephemeral22, xvdcx=ephemeral23, xvdcy=ephemeral24, xvdcz=ephemeral25
hvm
–
2025/10/31 13:15 GMT-5
disabled
ami-058cdf62ba6d6cd64
us-east-2

#######

Here's the newest Windows AMI from the CAST account:
AMI ID: ami-051537eaae7545f75
Name: amidistribution-2025-10-31T17-22-51.766Z
Created: October 31, 2025 at 17:44:49 UTC
Platform: Windows
Description: AMI distribution from Central Image Management Account
Tags: None (as we discovered earlier)
This matches the AMI in your JSON file. It's the latest available Windows AMI from the Image Builder account (422228628991) in the us-east-2 region.


#cursors output
## no tags
export AWS_PROFILE=CASTSoftware_dev_925774240130_admin && aws ec2 describe-images --image-ids ami-051537eaae7545f75 --region us-east-2 --query 'Images[0].Tags' --output json | jq '.'

# aws ec2 describe-images --image-ids ami-051537eaae7545f75 --region us-east-2 --query 'Images[0].Tags' --output json 
aws ec2 describe-images --image-ids ami-051537eaae7545f75 --region us-east-2 --query 'Images' --output json 

 aws ec2 describe-images --image-ids ami-051537eaae7545f75 --region us-east-2 --json
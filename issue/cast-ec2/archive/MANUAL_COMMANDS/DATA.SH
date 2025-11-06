Based on the JSON output you provided, here is a detailed, verbose breakdown of the EC2 Image Builder build version `arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/3`.

---

## Image Overview and Status

This resource is an **AMI** (Amazon Machine Image) that has successfully completed its build process and is ready for use.

| Detail | Value |
| :--- | :--- |
| **Full ARN** | `arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/3` |
| **Image Name** | `WinServer2022` |
| **Version** | `1.0.3/3` (Semantic Version `1.0.3`, Build Number `3`) |
| **Platform / OS** | **Windows** / `Microsoft Windows Server 2022` |
| **Status** | **`AVAILABLE`** |
| **Creation Date** | `2025-10-31T16:02:47.106Z` |
| **Source Pipeline** | `arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2022` |
| **Build Type** | `USER_INITIATED` (Manually triggered build) |

---

## Image Recipe Details

The recipe defines the source image and the customizations applied.

| Detail | Value |
| :--- | :--- |
| **Recipe ARN** | `arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2022/1.0.3` |
| **Base Image (`parentImage`)** | `arn:aws:imagebuilder:us-east-2:aws:image/windows-server-2022-english-full-base-x86/2025.10.15/1` (A monthly-updated, AWS-owned Windows Server 2022 base image.) |
| **Root Volume Size** | **100 GB** |
| **Root Volume Type** | **`gp3`** with 3000 **IOPS** and 125 **Throughput** |
| **Root Volume Encryption** | **Encrypted** using KMS Key ID: `arn:aws:kms:us-east-2:422228628991:alias/image-key` |
| **Working Directory** | `C:/` |

### Customization Components

The image was customized by applying the following components (software and configuration steps), which were executed sequentially:

1.  `arn:aws:imagebuilder:us-east-2:aws:component/amazon-cloudwatch-agent-windows/1.0.0/1`
2.  `arn:aws:imagebuilder:us-east-2:aws:component/aws-cli-version-2-windows/1.0.0/1`
3.  `arn:aws:imagebuilder:us-east-2:422228628991:component/step1-setup-workingdirectory-windows/1.0.2/1`
4.  `arn:aws:imagebuilder:us-east-2:422228628991:component/step2-s3-download-windows/1.0.3/1`
5.  `arn:aws:imagebuilder:us-east-2:422228628991:component/step3-crowdstrike-installation-windows/1.0.1/1` **(CrowdStrike installed)**
6.  `arn:aws:imagebuilder:us-east-2:422228628991:component/step4-qualys-installation-windows/1.0.2/1` **(Qualys installed)**
7.  `arn:aws:imagebuilder:us-east-2:422228628991:component/step5-mecm-staging-windows/1.0.0/1` **(MECM/SCCM Staging)**
8.  `arn:aws:imagebuilder:us-east-2:422228628991:component/step6-startup-job-setup-windows/1.0.2/1`

---

## Infrastructure Configuration

This specifies the environment the image was built in.

| Detail | Value |
| :--- | :--- |
| **Configuration Name** | `ec2-image-builder` |
| **Instance Type** | `t3.medium` |
| **Instance Profile** | `ec2-image-builder-instance-profile` |
| **Subnet ID** | `subnet-0696ffc1ce55e5839` |
| **Security Group ID** | `sg-0abb038a635a6127e` |
| **Key Pair** | `image-builder-keypair` |
| **Failure Policy** | `terminateInstanceOnFailure`: `false` (Builder instance remains after a failure) |
| **Notifications** | Alerts are sent to SNS Topic: `arn:aws:sns:us-east-2:422228628991:bread-imagemanagement-alerts` |

---

## Output Resources and Distribution

This section details the resulting AMIs and how they were distributed across regions.

### Resulting AMI IDs

The AMI build produced two AMIs in different regions:

| Region | AMI ID |
| :--- | :--- |
| **us-east-2** | **`ami-0b93d33915f052230`** |
| **us-west-2** | **`ami-0489affd6180a1962`** |

### Distribution Settings

The distribution configuration dictates how the AMIs were shared and tagged after creation.

| Detail | Value |
| :--- | :--- |
| **Distribution Configuration ARN** | `arn:aws:imagebuilder:us-east-2:422228628991:distribution-configuration/ec2-image-builder` |
| **Distribution Regions** | `us-east-2` and `us-west-2` |
| **Target Account IDs** | **`422228628991`** (Both AMIs are owned by this account) |
| **AMI Tags** | `Name`: `GoldenAMI` |
| **Launch Permissions** | The AMI is shared with all accounts within the AWS Organization `arn:aws:organizations::739275453939:organization/o-6wrht8pxbo`. |

---

## Testing and Tagging

| Detail | Value |
| :--- | :--- |
| **Image Tests** | **Enabled** |
| **Test Timeout** | 720 minutes (12 hours) |
| **Scanning** | `imageScanningEnabled`: `false` |
| **Resource Tags (Build)** | {} (No tags directly on the build version itself) |
| **Resource Tags (Recipe/Infra/Distro)** | `bfh:environment`: `prd`, `bfh:support-group`: `bfh.awsinfrastructure` |
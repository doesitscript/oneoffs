# AWS and Terraform MCP Server Tools

## MCP Servers Configured

| Server Name | Command/Path | Status | Purpose |
|-------------|--------------|--------|---------|
| **aws_cdk_mcp** | `/Users/a805120/.mcp-venv/aws-cdk-mcp/bin/awslabs.cdk-mcp-server` | ✅ Enabled | AWS CDK guidance and best practices |
| **awslabs.aws-diagram-mcp-server** | `/Users/a805120/.mcp-venv/aws-diagram/bin/awslabs.aws-diagram-mcp-server` | ✅ Enabled | Generate AWS architecture diagrams |
| **awslabs.ccapi-mcp-server** | `/Users/a805120/.mcp-venv/ccapi/bin/awslabs.ccapi-mcp-server` | ✅ Enabled | AWS Cloud Control API operations |
| **terraform-mcp-server** | `/opt/homebrew/bin/terraform-mcp-server` | ✅ Enabled | HashiCorp Terraform operations |
| **awslabs.terraform-mcp-server** | `/Users/a805120/.mcp-venv/terraform-mcp/bin/awslabs.terraform-mcp-server` | ✅ Enabled | AWS Labs Terraform operations |

---

## AWS CDK MCP Server Tools

| Tool Name | Description | Parameters |
|-----------|-------------|------------|
| **CDKGeneralGuidance** | Get prescriptive CDK advice for building applications on AWS | None |
| **ExplainCDKNagRule** | Explain a specific CDK Nag rule with AWS Well-Architected guidance | `rule_id` (string) - CDK Nag rule ID (e.g., 'AwsSolutions-IAM4') |
| **CheckCDKNagSuppressions** | Check if CDK code contains Nag suppressions that require human review | `code` (string, optional) - CDK code to analyze<br>`file_path` (string, optional) - Path to CDK code file |
| **GenerateBedrockAgentSchema** | Generate OpenAPI schema for Bedrock Agent Action Groups from a Lambda file | `lambda_code_path` (string) - Path to Python Lambda file<br>`output_path` (string) - Where to save schema |
| **GetAwsSolutionsConstructPattern** | Search and discover AWS Solutions Constructs patterns | `pattern_name` (string, optional) - Pattern name<br>`services` (array, optional) - List of AWS services |
| **SearchGenAICDKConstructs** | Search for GenAI CDK constructs by name or type | `query` (string, optional) - Search term(s)<br>`construct_type` (string, optional) - Filter by type ('bedrock', etc.) |
| **LambdaLayerDocumentationProvider** | Provide documentation sources for Lambda layers | `layer_type` (string) - Type: "generic" or "python" |

---

## AWS Diagram MCP Server Tools

| Tool Name | Description | Parameters |
|-----------|-------------|------------|
| **generate_diagram** | Generate a diagram from Python code using the diagrams package | `code` (string) - Python diagrams DSL code<br>`filename` (string, optional) - Output filename<br>`workspace_dir` (string, optional) - Workspace directory<br>`timeout` (integer, default: 90) - Timeout in seconds |
| **get_diagram_examples** | Get example code for different types of diagrams | `diagram_type` (string, default: "all") - Type: aws, sequence, flow, class, k8s, onprem, custom, all |
| **list_icons** | List available icons from the diagrams package with optional filtering | `provider_filter` (string, optional) - Filter by provider (e.g., "aws", "gcp")<br>`service_filter` (string, optional) - Filter by service (e.g., "compute", "database") |

---

## AWS Cloud Control API MCP Server Tools

| Tool Name | Description | Parameters |
|-----------|-------------|------------|
| **get_resource_schema_information** | Get schema information for an AWS resource | `resource_type` (string) - AWS resource type (e.g., "AWS::S3::Bucket")<br>`region` (string, optional) - AWS region |
| **list_resources** | List AWS resources of a specified type | `resource_type` (string) - AWS resource type<br>`region` (string, optional) - AWS region<br>`analyze_security` (boolean, default: false) - Perform security analysis<br>`max_resources_to_analyze` (integer, default: 5) - Max resources to analyze |
| **generate_infrastructure_code** | Generate infrastructure code before resource creation or update | `resource_type` (string) - AWS resource type<br>`properties` (object) - Resource properties dictionary<br>`identifier` (string, default: "") - Resource identifier<br>`patch_document` (array) - RFC 6902 JSON Patch operations<br>`region` (string, optional) - AWS region<br>`credentials_token` (string) - From get_aws_session_info() |
| **explain** | Explain any data in clear, human-readable format (MANDATORY for infrastructure operations) | `content` (any, optional) - Data to explain<br>`generated_code_token` (string, default: "") - From generate_infrastructure_code<br>`context` (string, default: "") - Context description<br>`operation` (string, default: "analyze") - Operation type<br>`format` (string, default: "detailed") - Explanation format<br>`user_intent` (string, default: "") - User's purpose |
| **get_resource** | Get details of a specific AWS resource | `resource_type` (string) - AWS resource type<br>`identifier` (string) - Resource identifier<br>`region` (string, optional) - AWS region<br>`analyze_security` (boolean, default: false) - Perform security analysis |
| **update_resource** | Update an AWS resource | `resource_type` (string) - AWS resource type<br>`identifier` (string) - Resource identifier<br>`patch_document` (array, default: []) - RFC 6902 JSON Patch operations<br>`region` (string, optional) - AWS region<br>`credentials_token` (string) - From get_aws_session_info()<br>`explained_token` (string) - From explain()<br>`security_scan_token` (string, default: "") - From run_checkov()<br>`skip_security_check` (boolean, default: false) |
| **create_resource** | Create an AWS resource | `resource_type` (string) - AWS resource type<br>`region` (string, optional) - AWS region<br>`credentials_token` (string) - From get_aws_session_info()<br>`explained_token` (string) - From explain()<br>`security_scan_token` (string, default: "") - From approve_security_findings()<br>`skip_security_check` (boolean, default: false) |
| **delete_resource** | Delete an AWS resource | `resource_type` (string) - AWS resource type<br>`identifier` (string) - Resource identifier<br>`region` (string, optional) - AWS region<br>`credentials_token` (string) - From get_aws_session_info()<br>`confirmed` (boolean, default: false) - Confirm deletion<br>`explained_token` (string) - From explain() |
| **get_resource_request_status** | Get the status of a long running operation | `request_token` (string) - Request token from operation<br>`region` (string, optional) - AWS region |
| **run_checkov** | Run Checkov security and compliance scanner on CloudFormation template | `explained_token` (string) - From explain() containing CloudFormation template<br>`framework` (string, default: "cloudformation") - Framework to scan |
| **create_template** | Create a CloudFormation template from existing resources using IaC Generator API | `template_name` (string, optional) - Template name<br>`resources` (array, optional) - List of resources with ResourceType and ResourceIdentifier<br>`output_format` (string, default: "YAML") - Format: JSON or YAML<br>`deletion_policy` (string, default: "RETAIN") - DeletionPolicy<br>`update_replace_policy` (string, default: "RETAIN") - UpdateReplacePolicy<br>`template_id` (string, optional) - Existing template ID<br>`save_to_file` (string, optional) - Path to save template<br>`region` (string, optional) - AWS region |
| **check_environment_variables** | Check if required environment variables are set correctly | None |
| **get_aws_session_info** | Get information about the current AWS session | `environment_token` (string) - From check_environment_variables() |
| **get_aws_account_info** | Get information about the current AWS account being used | None |

---

## Terraform MCP Server Tools (HashiCorp)

| Tool Name | Description | Parameters |
|-----------|-------------|------------|
| **get_latest_module_version** | Fetches the latest version of a Terraform module from the public registry | `module_name` (string) - Module name (e.g., 'security-group')<br>`module_provider` (string) - Provider name (e.g., 'aws')<br>`module_publisher` (string) - Publisher (e.g., 'hashicorp', 'aws-ia') |
| **get_latest_provider_version** | Fetches the latest version of a Terraform provider from the public registry | `name` (string) - Provider name (e.g., 'aws')<br>`namespace` (string) - Provider namespace (e.g., 'hashicorp') |
| **get_module_details** | Fetches up-to-date documentation on how to use a Terraform module | `module_id` (string) - Exact module_id from search_modules (e.g., 'squareops/terraform-kubernetes-mongodb/mongodb/2.1.1') |
| **get_policy_details** | Fetches up-to-date documentation for a specific policy from Terraform registry | `terraform_policy_id` (string) - Policy ID from search_policies |
| **get_provider_details** | Fetches up-to-date documentation for a specific service from a Terraform provider | `provider_doc_id` (string) - Provider doc ID from search_providers |
| **search_modules** | Resolves a Terraform module name to obtain a compatible module_id | `module_query` (string) - Query to search for modules<br>`current_offset` (integer, default: 0) - Pagination offset |
| **search_policies** | Searches for Terraform policies based on a query string | `policy_query` (string) - Query to search for policies |
| **search_providers** | Retrieves a list of potential documents based on service_slug and provider_data_type | `provider_name` (string) - Provider name<br>`provider_namespace` (string) - Provider namespace<br>`service_slug` (string) - Service slug (e.g., 's3_bucket')<br>`provider_data_type` (string, default: "resources") - Type: resources, data-sources, functions, guides, overview<br>`provider_version` (string, optional) - Provider version (e.g., 'x.y.z' or 'latest') |

---

## AWS Labs Terraform MCP Server Tools

| Tool Name | Description | Parameters |
|-----------|-------------|------------|
| **ExecuteTerraformCommand** | Execute Terraform workflow commands against an AWS account | `command` (string) - Command: init, plan, validate, apply, destroy<br>`working_directory` (string) - Directory containing Terraform files<br>`variables` (object, optional) - Terraform variables<br>`aws_region` (string, optional) - AWS region<br>`strip_ansi` (boolean, default: true) - Strip ANSI color codes |
| **ExecuteTerragruntCommand** | Execute Terragrunt workflow commands against an AWS account | `command` (string) - Command: init, plan, validate, apply, destroy, output, run-all<br>`working_directory` (string) - Directory containing Terragrunt files<br>`variables` (object, optional) - Terraform variables<br>`aws_region` (string, optional) - AWS region<br>`strip_ansi` (boolean, default: true) - Strip ANSI color codes<br>`include_dirs` (array, optional) - Directories to include<br>`exclude_dirs` (array, optional) - Directories to exclude<br>`run_all` (boolean, default: false) - Run on all modules<br>`terragrunt_config` (string, optional) - Path to custom config |
| **SearchAwsProviderDocs** | Search AWS provider documentation for resources and attributes | `asset_name` (string) - Service name (e.g., 'aws_s3_bucket')<br>`asset_type` (string, default: "resource") - Type: resource, data_source, or both |
| **SearchAwsccProviderDocs** | Search AWSCC provider documentation for resources and attributes | `asset_name` (string) - Service name (e.g., 'awscc_s3_bucket')<br>`asset_type` (string, default: "resource") - Type: resource, data_source, or both |
| **SearchSpecificAwsIaModules** | Search for specific AWS-IA Terraform modules | `query` (string) - Search term to filter modules |
| **RunCheckovScan** | Run Checkov security scan on Terraform code | `working_directory` (string) - Directory containing Terraform files<br>`framework` (string, default: "terraform") - Framework to scan<br>`check_ids` (array, optional) - Specific check IDs to run<br>`skip_check_ids` (array, optional) - Check IDs to skip<br>`output_format` (string, default: "json") - Format for results |
| **SearchUserProvidedModule** | Search for a user-provided Terraform registry module and understand its inputs, outputs, and usage | `module_url` (string) - Module URL (e.g., "hashicorp/consul/aws")<br>`version` (string, optional) - Specific version<br>`variables` (object, optional) - Variables to use when analyzing |

---

## Tool Usage Summary by Category

### AWS Resource Management
- **Create/Update/Delete**: `create_resource`, `update_resource`, `delete_resource` (CCAPI)
- **List/Query**: `list_resources`, `get_resource` (CCAPI)
- **Code Generation**: `generate_infrastructure_code` (CCAPI)
- **Template Generation**: `create_template` (CCAPI) - Generate CloudFormation from existing resources

### Terraform Operations
- **Command Execution**: `ExecuteTerraformCommand`, `ExecuteTerragruntCommand` (AWS Labs)
- **Module Discovery**: `search_modules`, `get_module_details` (HashiCorp)
- **Provider Docs**: `SearchAwsProviderDocs`, `SearchAwsccProviderDocs` (AWS Labs)
- **Module Analysis**: `SearchUserProvidedModule` (AWS Labs)

### Security & Compliance
- **Security Scanning**: `run_checkov`, `RunCheckovScan` (CCAPI, AWS Labs)
- **Nag Rule Checking**: `CheckCDKNagSuppressions`, `ExplainCDKNagRule` (CDK)
- **Security Analysis**: `analyze_security` parameter in `list_resources`, `get_resource` (CCAPI)

### Documentation & Guidance
- **CDK Guidance**: `CDKGeneralGuidance`, `ExplainCDKNagRule` (CDK)
- **AWS Solutions**: `GetAwsSolutionsConstructPattern` (CDK)
- **Provider Documentation**: `get_provider_details`, `get_module_details` (HashiCorp)
- **Policy Documentation**: `get_policy_details` (HashiCorp)

### Diagramming
- **Architecture Diagrams**: `generate_diagram`, `get_diagram_examples`, `list_icons` (AWS Diagram)
- **Diagram Types**: AWS, sequence, flow, class, Kubernetes, on-premises, custom

### AWS Account/Session Management
- **Session Info**: `get_aws_session_info`, `get_aws_account_info` (CCAPI)
- **Environment Check**: `check_environment_variables` (CCAPI)

---

## Workflow Patterns

### Creating AWS Resources
1. `check_environment_variables()` → Get `environment_token`
2. `get_aws_session_info(environment_token)` → Get `credentials_token`
3. `generate_infrastructure_code(resource_type, properties, credentials_token)` → Get `generated_code_token`
4. `explain(generated_code_token, operation="create")` → Get `explained_token` (MANDATORY)
5. `run_checkov(explained_token)` → Get `security_scan_token` (if enabled)
6. `create_resource(resource_type, credentials_token, explained_token, security_scan_token)`

### Terraform Module Discovery
1. `search_modules(module_query)` → Find modules
2. `get_module_details(module_id)` → Get detailed documentation
3. `SearchAwsProviderDocs(asset_name)` → Get provider documentation

### Security Scanning
1. **For CloudFormation**: `run_checkov(explained_token, framework="cloudformation")`
2. **For Terraform**: `RunCheckovScan(working_directory, framework="terraform")`

---

## Notes

- **Auto-approve**: All AWS/CCAPI tools are auto-approved (configured in mcp.json)
- **Security**: Checkov scanning is recommended for all infrastructure changes
- **Explain Tool**: MANDATORY to call before create/update/delete operations
- **Credentials**: Always use tokens from `get_aws_session_info()` for AWS operations
- **Region Support**: Most tools support region parameter for multi-region operations


package mcp.policies

# Simple allow-list policy for Figma MCP tools with basic input guards
# Input example:
# {
#   "tool": { "name": "get_code" },
#   "params": { "fileKey": "...", "nodeId": "1:2", "options": {"screenshot": true} }
# }

default allow = false

allowed_tools := {"get_code", "get_metadata", "get_screenshot", "create_design_system_rules"}

allow {
  allowed_tools[input.tool.name]
  valid_params
}

valid_params {
  # Ensure params exist and are not too large
  input.params
  not too_large
}

too_large {
  # crude payload size guard (approx by string length when serialized)
  json.marshal(input.params, s)
  count(s) > 200000 # ~200 KB
}

deny[msg] {
  not allow
  msg := "Request denied by OPA policy (tool not allowed or params invalid)"
}
package mcp.policy.toolio

default allow_input = false
default allow_output = false

# Parameters
max_input_bytes := 262144  # 256 KiB
allowed_services := {"api", "crm", "frontend", "games", "website", "n8n", "root"}

# Input schema: {
#   "service": string,
#   "filePath": string,
#   "args": object (optional)
# }

allow_input {
  input.service != ""
  input.filePath != ""
  input.service \u2208 allowed_services
  not path_traversal(input.filePath)
  input_size_ok
}

input_size_ok {
  not input._bytes
}
input_size_ok {
  input._bytes <= max_input_bytes
}

path_traversal(p) {
  contains(p, "../")
} else {
  startswith(p, "/")
} else {
  contains(p, "..\\")
}

# Output schema: {
#   "content": string | array
# }

allow_output {
  not contains(to_string(input.content), "-----BEGIN PRIVATE KEY-----")
  not contains(to_string(input.content), "AWS_SECRET_ACCESS_KEY")
  not contains(to_string(input.content), "x-api-key")
}

to_string(x) = s {
  s := sprintf("%v", [x])
}


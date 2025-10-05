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


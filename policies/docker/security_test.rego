package main

import future.keywords.if

# 1. TESTE: Deve falhar se usar usuário root ("root")
test_deny_root_user if {
    d := [
        {"Cmd": "from", "Value": ["node:18-alpine"]},
        {"Cmd": "user", "Value": ["root"]}
    ]
    deny[msg] with input as d
}

# 2. TESTE: Deve falhar se usar usuário root numérico ("0")
test_deny_numeric_root_user if {
    d := [
        {"Cmd": "from", "Value": ["node:18-alpine"]},
        {"Cmd": "user", "Value": ["0"]}
    ]
    deny[msg] with input as d
}

# 3. TESTE: Deve falhar se usar a tag :latest no FROM
test_deny_latest_tag if {
    d := [
        {"Cmd": "from", "Value": ["node:latest"]},
        {"Cmd": "user", "Value": ["node"]}
    ]
    deny[msg] with input as d
}

# 4. TESTE: Deve passar (sem violações) se o Dockerfile estiver seguro
test_allow_secure_dockerfile if {
    d := [
        {"Cmd": "from", "Value": ["node:18-alpine"]},
        {"Cmd": "user", "Value": ["node"]}
    ]
    count(deny) == 0 with input as d
}
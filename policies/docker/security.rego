package main

import future.keywords.if
import future.keywords.contains

# Regra: Bloqueia a build se o Dockerfile não definir um usuário não-root
deny contains msg if {
    not tem_usuario_nao_root
    msg := "VIOLAÇÃO DE SEGURANÇA: O Dockerfile precisa definir um USER diferente de root."
}

tem_usuario_nao_root if {
    input[i].Cmd == "user"
    input[i].Value[0] != "root"
    input[i].Value[0] != "0"
}
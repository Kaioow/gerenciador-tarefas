package com.projeto.gerenciado_tarefas.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginResponse {
    private String idUsuario;
    private String nome;
    private String grupo;
}

package com.projeto.gerenciado_tarefas.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "usuarios")
public class Usuario {

    @Id
    @Column(name = "id_usuario", length = 20)
    private String idUsuario;

    @Column(nullable = false, length = 100)
    private String nome;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(name = "senha_hash", nullable = false, length = 255)
    private String senhaHash;

    @ManyToOne
    @JoinColumn(name = "id_grupo", nullable = false)
    private GrupoUsuario grupo;

    @Column(nullable = false)
    private boolean ativo = true;
}

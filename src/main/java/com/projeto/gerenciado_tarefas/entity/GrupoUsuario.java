package com.projeto.gerenciado_tarefas.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "grupos_usuarios")
public class GrupoUsuario {

    @Id
    @Column(name = "id_grupo", length = 10)
    private String idGrupo;

    @Column(nullable = false, length = 50)
    private String nome;

    @Column(length = 255)
    private String descricao;
}

package com.projeto.gerenciado_tarefas.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "listas_tarefas")
public class ListaTarefas {

    @Id
    @Column(name = "id_lista", length = 20)
    private String idLista;

    @Column(nullable = false, length = 100)
    private String nome;

    @Column(length = 255)
    private String descricao;

    @ManyToOne
    @JoinColumn(name = "id_usuario_dono", nullable = false)
    private Usuario dono;
}

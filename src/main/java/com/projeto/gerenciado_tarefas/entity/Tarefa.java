package com.projeto.gerenciado_tarefas.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "tarefas")
public class Tarefa {

    @Id
    @Column(name = "id_tarefa", length = 20)
    private String idTarefa;

    @Column(nullable = false, length = 150)
    private String titulo;

    @Column(columnDefinition = "TEXT")
    private String descricao;

    @Column(nullable = false, length = 20)
    private String status;

    @Column(length = 20)
    private String prioridade;

    @Column(name = "data_criacao")
    private LocalDateTime dataCriacao;

    @Column(name = "data_limite")
    private LocalDate dataLimite;

    @ManyToOne
    @JoinColumn(name = "id_lista", nullable = false)
    private ListaTarefas lista;

    @ManyToOne
    @JoinColumn(name = "id_usuario_responsavel")
    private Usuario responsavel;
}

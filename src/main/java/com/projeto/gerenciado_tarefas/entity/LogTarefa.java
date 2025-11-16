package com.projeto.gerenciado_tarefas.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@Document(collection = "logs_tarefas")
public class LogTarefa {

    @Id
    private String id;

    private String idTarefa;
    private String usuario;
    private String acao;
    private String statusAnterior;
    private String statusNovo;
    private LocalDateTime dataHora;
    private String origem;
    private String detalhes;
}

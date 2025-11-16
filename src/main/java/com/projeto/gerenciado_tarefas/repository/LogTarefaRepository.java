package com.projeto.gerenciado_tarefas.repository;

import com.projeto.gerenciado_tarefas.entity.LogTarefa;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface LogTarefaRepository extends MongoRepository<LogTarefa, String> {
}

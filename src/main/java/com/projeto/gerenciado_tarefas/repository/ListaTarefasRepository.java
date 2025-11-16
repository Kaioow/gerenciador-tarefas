package com.projeto.gerenciado_tarefas.repository;

import com.projeto.gerenciado_tarefas.entity.ListaTarefas;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ListaTarefasRepository extends JpaRepository<ListaTarefas, String> {
}
